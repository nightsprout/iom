module ModelChangesRecorder
  @@included_in = []

  def self.included_in
    @@included_in
  end

  def self.included(base)

    base.class_eval do
      has_many  :changes_history_records, :foreign_key => :what_id, :order => 'changes_history_records.when desc'

      after_save :record_changes
    end if defined?(ActiveRecord::Base) && base < ActiveRecord::Base

    base.send :include, InstanceMethods
    base.send :extend, ClassMethods

    @@included_in << base
  end

  module InstanceMethods
    attr_accessor :updated_by

    def last_changes
      (changes || []).reject{|field, values| %w(created_at updated_at).include?(field)}
    end

    def record_changes
      valid_changes = valid(last_changes)
      return if valid_changes.blank? || updated_by.nil?

      self.changes_history_records << ChangesHistoryRecord.create!(
        :who              => updated_by,
        :who_email        => updated_by.email,
        :who_organization => (updated_by.organization.name rescue nil),
        :what             => self,
        :how              => valid_changes.to_json,
        :when             => Time.now
      )
    end

    def record_new_associated_object(child)
      changed_attributes[child.class.name.tableize]    = [] if changed_attributes[child.class.name.tableize].nil?
      changed_attributes[child.class.name.tableize][0] = (changed_attributes[child.class.name.tableize][0] || []) + [{:new => change_label_for(child)}]
    end

    def record_deleted_associated_object(child)
      changed_attributes[child.class.name.tableize]    = [] if changed_attributes[child.class.name.tableize].nil?
      changed_attributes[child.class.name.tableize][0] = (changed_attributes[child.class.name.tableize][0] || []) + [{:deleted => change_label_for(child)}]
    end

    def valid(changes)
      if changes[:countries].present?        
        changes[:countries] = changes[:countries].map do |c|
          if c.respond_to? :id
            Country.select([:id, :name]).where(id: c.id)
          elsif c.respond_to? :map
            c.map { |e| e.respond_to? :id ? Country.select([:id, :name]).where(id: e.id) : e }
          else
            c
          end
        end
      end
      
      if changes[:regions].present?
        changes[:regions] = changes[:regions].map do |r|
          if r.respond_to? :id
            Region.select([:id, :name]).where(id: r.id)
          elsif r.respond_to? :map
            r.map { |e| e.respond_to? :id ? Region.select([:id, :name]).where(id: e.id) : e }
          else
            r
          end
        end
      end

      associations_changes = Hash[changes.select do |field, values|
        old, new = *values
        old.is_a?(Array)
      end]

      associations_changes = associations_changes.each do |k,v|
        deletes = v.first.flatten.select{|o| o[:deleted].present?}.map(&:values).flatten
        news = v.first.flatten.select{|o| o[:new].present?}.map(&:values).flatten
        v.first.first.reject!{|hash| deletes.include?(hash.values.first) && news.include?(hash.values.first)}
      end.reject{|k,v| v.first.first.flatten.blank?}

      fields_changes = changes.reject do |field, values|
        old, new = *values
        old.is_a?(Array) || new.is_a?(String) && old.presence.try(:strip) == new.presence.try(:strip)
      end

      associations_changes.merge(fields_changes)
    end

    def change_label_for(model)
      model.name rescue model.change_label rescue model.to_s
    end
    private :change_label_for
  end

  module ClassMethods

    def has_many(association_name, options = {}, &block)
      options[:after_add]    = [options[:after_add], :record_new_associated_object].compact.flatten
      options[:after_remove] = [options[:after_remove], :record_deleted_associated_object].compact.flatten

      super(association_name, options, &block)
    end

    def has_and_belongs_to_many(association_name, options = {}, &block)
      options[:after_add]    = [options[:after_add], :record_new_associated_object].compact.flatten
      options[:after_remove] = [options[:after_remove], :record_deleted_associated_object].compact.flatten

      super(association_name, options, &block)
    end
  end

end
