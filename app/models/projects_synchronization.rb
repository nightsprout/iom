# == Schema Information
#
# Table name: projects_synchronizations
#
#  id                 :integer          not null, primary key
#  projects_file_data :text
#  created_at         :datetime
#  updated_at         :datetime
#

class ProjectsSynchronization < ActiveRecord::Base

  REQUIRED_HEADERS = %w(organization project_name project_description start_date end_date sectors location)

  attr_accessor :projects_file, :projects_errors, :user

  serialize :projects_file_data, Array

  validates_presence_of :projects_file, :on => :create

  before_save :process_projects_file_data
  before_update :save_projects_anyway

  def valid?(context = nil)
    super && projects_errors.blank?
  end

  def setup_book
    book = Spreadsheet.open projects_file.tempfile
    book.add_format Spreadsheet::Format.new(:number_format => 'MM/DD/YYYY')

    convert_file_to_hash_array(book.worksheet(0))
  end

  def projects_errors
    @projects_errors ||= []
  end

  def projects_errors_count
    projects_errors.size
  end

  def projects_updated_count
    @projects.count
  end

  def as_json(options = {})
    {
      :id                         => id,
      :success                    => self.valid?,
      :title                      => "There are #{projects_errors_count} problems with the selected file",
      :errors                     => projects_errors,
      :projects_updated_count     => projects.count,
      :projects_not_updated_count => project_not_updated.count
    }
  end


  def self.load_project_files( csv_projs, ps = nil )
    line = 0
    csv_projs.each do |row|
      line += 1
      begin
        Rails.logger.debug "=== #{line} ==="
        o = Organization.find_by_name row.organization
        o = Organization.create!( :name => row.organization ) if o.nil?

        if defined?(row.interaction_intervention_id) && row.interaction_intervention_id.present?
          p = o.projects.where(:name => row.project_name, :organization_id => row.org_intervention_id, :intervention_id => row.interaction_intervention_id).first
        else
          p = o.projects.where(:name => row.project_name, :organization_id => row.org_intervention_id).first
        end

        p = Project.new if p.nil?

        p.assign_attributes({
          :primary_organization_id  => o.id,
          :organization_id          => row.org_intervention_id,
          :name                     => row.project_name.present? ? row.project_name.gsub(/\|/, ", ") : nil,
          :description              => row.project_description,
          :additional_information   => row.additional_information,
          :budget                   => row.budget_numeric,
          :partner_organizations    => row.local_partners,
          :estimated_people_reached => row.estimated_people_reached
        })

        p.intervention_id           = row.interaction_intervention_id if defined?( row.interaction_intervention_id ) && row.interaction_intervention_id.present?

        p.contact_person            = row.project_contact_person if defined?( row.project_contact_person ) && row.project_contact_person.present?
        p.contact_email             = row.project_contact_email if defined?( row.project_contact_email ) && row.project_contact_email.present? 
        p.contact_position          = row.project_contact_position if defined?( row.project_contact_position) && row.project_contact_position.present?
        p.contact_phone_number      = row.project_contact_phone_number if defined?( row.project_contact_phone_number) && row.project_contact_phone_number.present?
        p.website                   = row.project_website if defined?( row.project_website) && row.project_website.present?

        p.implementing_organization = row.international_partners if defined?( row.international_partners ) && row.international_partners.present? 
        p.partner_organizations     = row.local_partners if defined?( row.local_partners ) && row.local_partners.present?
        p.cross_cutting_issues      = row.cross_cutting_issues if defined?( row.cross_cutting_issues ) && row.cross_cutting_issues.present? 
        p.target                    = row.target_groups if defined?( row.target_groups) && row.target_groups.present?
        p.verbatim_location         = row.verbatim_location if defined?( row.verbatim_location) && row.verbatim_location.present?
        p.idp_refugee_camp          = row.idp_refugee_camp if defined?( row.idp_refugee_camp ) && row.idp_refugee_camp.present?
        p.project_needs             = row.project_needs if defined?( row.project_needs ) && row.project_needs.present?

        if not defined?(row.date_provided) or row.date_provided.blank?
          p.date_provided = Date.today
        else
          begin
            p.date_provided = Date.strptime( row.date_provided, '%m/%d/%Y' )
          rescue
            p.date_provided = nil
          end
        end

        # verbatim locations
        if row.start_date.blank?
          p.start_date = Time.now - 1.year
        else
          begin
            p.start_date = Date.strptime( row.start_date, '%m/%d/%Y' )
          rescue
            p.start_date = nil
          end
        end

        if row.end_date.blank?
          p.end_date = Time.now + 1.year
        else
          begin
            p.end_date = Date.strptime( row.end_date, '%m/%d/%Y' )
          rescue
            p.end_date = nil
          end
        end  

        Rails.logger.debug "===== Region Load"
        unless row.location.blank?
          p.countries.delete_all unless p.new_record?
          p.regions.delete_all unless p.new_record?

          Rails.logger.debug row.location
          row.location.split("|").map(&:strip).each do |loc|
            loc_array = loc.split(">").map(&:strip)

            if loc_array[0].present?
              c = Country.fast.find_by_name_insensitive loc_array[0]
              next if c.nil?
              p.countries << c unless p.countries.fast.include?( c )
              Rails.logger.debug c
              if loc_array[1].present?
                r = c.regions.fast.find_by_name_insensitive loc_array[1]
                next if r.nil?
                p.regions << r unless p.regions.fast.include?( r )
                Rails.logger.debug r

                if loc_array[2].present?
                  r2 = Region.fast.where(:country_id => c.id, :parent_region_id => r.id).find_by_name_insensitive loc_array[2]
                  next if r2.nil?
                  p.regions << r2 unless p.regions.fast.include?( r2 )
                  Rails.logger.debug r2
                end
              end
            end

          end
        end

        Rails.logger.debug "===== Sector Load"
        unless !defined?(row.sectors) or row.sectors.blank?
          p.sectors.delete_all unless p.new_record?
          row.sectors.split("|").map(&:strip).each do |sec|
            sec = CGI::escapeHTML(sec)
            sect = Sector.find_by_name_ilike sec
            if sect.nil?
              sect = Sector.create(:name => sec)
            end
            p.sectors << sect unless p.sectors.include?( sect )
          end
        end

        Rails.logger.debug "===== Audience Load"
        unless !defined?(row.audience) or row.audience.blank?
          p.audiences.delete_all unless p.new_record?
          row.audience.split("|").map(&:strip).each do |aud|
            aud = CGI::escapeHTML(aud)
            a = Audience.find_by_name_ilike aud
            if a.nil?
              a = Audience.create(:name => aud)
            end
            p.audiences << a unless p.audiences.include?( a )
          end
        end

        Rails.logger.debug "===== Activities Load"
        unless !defined?(row.activities) or row.activities.blank?
          p.activities.delete_all unless p.new_record?
          row.activities.split("|").map(&:strip).each do |act|
            act = CGI::escapeHTML(act)
            a = Activity.find_by_name_ilike act
            if a.nil?
              a = Activity.create(:name => act)
            end
            p.activities << a unless p.activities.include?( a )
          end
        end

        Rails.logger.debug "===== Disease Load"
        unless !defined?(row.diseases) or row.diseases.blank?
          p.diseases.delete_all unless p.new_record?
          row.diseases.split("|").map(&:strip).each do |dis|
            dis = CGI::escapeHTML(dis)
            a = Disease.find_by_name_ilike dis
            if a.nil?
              a = Disease.create(:name => dis)
            end
            p.diseases << a unless p.diseases.include?( a )
          end
        end

        Rails.logger.debug "===== Medicine Load"
        unless !defined?(row.medicine) or row.medicine.blank?
          p.medicines.delete_all unless p.new_record?
          row.medicine.split("|").map(&:strip).each do |med|
            med = CGI::escapeHTML(med)
            a = Medicine.find_by_name_ilike med
            if a.nil?
              a = Medicine.create(:name => med)
            end
            p.medicines << a unless p.medicines.include?( a )
          end
        end


        Rails.logger.debug "===== Donors Load"
        unless !defined?(row.donors) or row.donors.blank?
          p.donations.delete_all unless p.new_record?
          row.donors.split("|").map(&:strip).each do |don|
            don = CGI::escapeHTML(don)
            donor = Donor.find_by_name_ilike don
            if donor.nil?
              donor = Donor.create!(:name => don)
            end
            p.donations << Donation.new( :project => p, :donor => donor) unless p.donations.where( :donor_id => donor.id).count > 0
          end
        end
        
        Rails.logger.debug "===== Data Sources Load"
        unless !defined?(row.data_source) or row.data_source.blank?
          p.data_sources.delete_all unless p.new_record?
          row.data_source.split("|").map(&:strip).each do |src|
            src = CGI::escapeHTML(src)
            data_source = DataSource.find_by_name_ilike src
            if data_source.nil?
              data_source = DataSource.create!(:name => src)
            end
            p.data_sources << data_source unless p.data_sources.include?( data_source )
          end
        end

        if ps.present?
          if p.invalid?
            ps.projects_errors += p.errors.full_messages.flatten.map{|msg| "#{msg} on row ##{line}"}
            ps.project_not_updated << p
          else
            ps.projects << p
          end
        end
        
        if p.save
          p.sites << Site.find_by_name("global")
        end
        
      rescue Exception => e
        Rails.logger.debug "Exception: #{e}"
        ps.projects_errors << "Unable to update project on row #{line}"
        ps.project_not_updated << p
        nil
      end
    end
  end







  def projects
    @projects ||= []
  end

  def project_not_updated
    @project_not_updated ||= []
  end

  private

  def process_projects_file_data
    input = File.read(projects_file.tempfile)

    begin
      parsed_input = CSV.parse(input)
    rescue ArgumentError => e
      input = File.read(projects_file.tempfile, encoding: "ISO-8859-1")
      parsed_input = CSV.parse(input)
    end      

    headers = parsed_input[0].map { |column| column.present? ? column.to_sym : :"_none_" }
    body = parsed_input[1..-1]

    sync_row = Struct.new(*headers.map(&:to_sym))

    results = body.map { |row| sync_row.new(*row) }

    ProjectsSynchronization.load_project_files( results, self )
  end

  def save_projects_anyway
    projects.each(&:save)
    self.destroy
  end

  def projects_ids_to_delete
    @projects_ids_to_delete ||= []
  end

  def csv_projects
    @csv_projects ||= []
  end


  def instantiate_project(project_hash)
    if project_hash['interaction_intervention_id'].present?
      Project.where('lower(trim(intervention_id)) = lower(trim(?))', project_hash['interaction_intervention_id'].try(:to_s)).first || Project.new
    else
      Project.new
    end
  end

end
