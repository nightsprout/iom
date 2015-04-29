'use strict';

define(['backbone'], function(Backbone) {

  var DownloadsView = Backbone.View.extend({

    el: '#downloadsView',

    events: {
      'click #embedMapBtn': 'showEmbedOverlay',
      'click #exportCsvBtn': 'triggerExport',
      'click #exportXlsBtn': 'triggerExport',
      'click #exportKmlBtn': 'triggerExport'
    },

    showEmbedOverlay: function(e) {
      Backbone.Events.trigger('embed:show');
      e.preventDefault();
    },

    triggerExport: function(e) {
      $.ajax({url: e.target.href });
      Backbone.Events.trigger('export:show');
      e.preventDefault();
    }

  });

  return DownloadsView;

});
