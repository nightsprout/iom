'use strict';

define(['backbone'], function(Backbone) {

  var DownloadsView = Backbone.View.extend({

    el: '#downloadsView',

    events: {
      'click #embedMapBtn': 'showEmbedOverlay',
      'click #exportCsvBtn': 'showExportOverlay',
      'click #exportXlsBtn': 'showExportOverlay',
      'click #exportKmlBtn': 'showExportOverlay'
    },

    showEmbedOverlay: function(e) {
      Backbone.Events.trigger('embed:show');
      e.preventDefault();
    },

    showExportOverlay: function(e) {
      Backbone.Events.trigger('export:show');
      e.preventDefault();
    }

  });

  return DownloadsView;

});
