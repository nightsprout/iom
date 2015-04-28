'use strict';

define([
  'backbone',

  'views/clusters',
  'views/map',
  'views/filters',
  'views/menu-fixed',
  'views/downloads',
  'views/embed-map',
  'views/export-data',
  'views/search',
  'views/layer-overlay',
  'views/timeline',
  'views/donors-sidebar',
  'views/gallery'
], function(Backbone) {

  var ClustersView = arguments[1],
    MapView = arguments[2],
    FiltersView = arguments[3],
    MenuFixedView = arguments[4],
    DownloadsView = arguments[5],
    EmbedMapView = arguments[6],
    ExportDataView = arguments[7],
    SearchView = arguments[8],
    LayerOverlayView = arguments[9],
    TimelineView = arguments[10],
    DonorsSidebarView = arguments[11],
    GalleryView = arguments[12];

  var Router = Backbone.Router.extend({

    routes: {
      '': 'lists',
      'sectors/:id': 'lists',
      'sectors/:id/*params': 'lists',
      'organizations/:id': 'lists',
      'organizations/:id/*params': 'lists',
      'donors/:id': 'lists',
      'donors/:id/*params': 'lists',
      'activities/:id': 'lists',
      'activities/:id/*params': 'lists',
      'audience/:id': 'lists',
      'audience/:id/*params': 'lists',
      'diseases/:id': 'lists',
      'diseases/:id/*params': 'lists',
      'location/:id': 'lists',
      'location/:id/*params': 'lists',
      'projects/:id': 'project',
      'projects/:id/*params': 'project',
      'location/:region/:id': 'lists',
      'location/:region/:id/*regions': 'lists',
      'search': 'search',
      'p/:page': 'page'
    },

    initialize: function() {
      var pushState = !!(window.history && window.history.pushState);

      Backbone.history.start({
        pushState: pushState
      });
    },

    lists: function() {
      new ClustersView();
      new MapView();
      new FiltersView();
      new DownloadsView();
      new EmbedMapView();
      new ExportDataView();
      new LayerOverlayView();
      new DonorsSidebarView();
    },

    project: function() {
      this.lists();
      new TimelineView();
      new GalleryView();
    },

    search: function() {
      new SearchView();
    },

    page: function() {
      new MenuFixedView();

      $('#faqAccordion').accordion({
        heightStyle: 'content'
      });
    }

  });

  return Router;

});
