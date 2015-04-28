'use strict';

define(['backbone'], function(Backbone) {

  var ExportDataView = Backbone.View.extend({

    el: '#exportDataView',

    events: {
      'click': 'hide',
      'click .mod-overlay-close': 'hide',
      'click .mod-overlay-content': 'show'
    },

    initialize: function() {
      Backbone.Events.on('export:show', this.show, this);
    },

    show: function() {
      this.$el.stop().fadeIn();
      return false;
    },

    hide: function(e) {
      this.$el.fadeOut();
      if (e.preventDefault) {
        e.preventDefault();
        e.stopPropagation();
      }
      return false;
    }

  });

  return ExportDataView;

});
