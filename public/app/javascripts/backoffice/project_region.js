  $(document).ready(function (ev) {

    var selected_region_ids = ['0','0','0','0'];
    var selected_region_names = ['','','',''];

    var region_select_level_0_original = $('select#region_select_level_0').clone();
    var region_select_level_1_original = $('select#region_select_level_1').clone();
    var region_select_level_2_original = $('select#region_select_level_2').clone();
    var region_select_level_3_original = $('select#region_select_level_3').clone();

    var resetRegionLevel = function (level) {
      selected_region_ids[level] = '0';
      selected_region_names[level] = '';
    };

    var resetRegionValues = function () {
      resetRegionLevel(0);
      resetRegionLevel(1);
      resetRegionLevel(2);
      resetRegionLevel(3);

      $('.chzn-container#region_select_level_0_chzn').remove();
      $('select#region_select_level_0').replaceWith(region_select_level_0_original.clone()[0]);

      $('div.level_1').hide();
      $('div.level_2').hide();
      $('div.level_3').hide();
    };

    var region_select_level_0_onchange = function (ev) {      
      selected_region_ids[0] = ev.target.value;
      selected_region_names[0] = ev.target[ev.target.selectedIndex].text;

      resetRegionLevel(1);
      resetRegionLevel(2);
      resetRegionLevel(3);

      if (selected_region_ids[0] === '0') {
        $('div.level_1').hide();
        $('div.level_2').hide();
        $('div.level_3').hide();
        return;
      }

      $.getJSON('/geo/regions/1/' + selected_region_ids[0] + '/json', function (json) {
        var level_1_options = json;
        level_1_options.unshift({ name: "All", id: 0 });

        $('select#region_select_level_1').replaceWith(region_select_level_1_original.clone()[0]);
        var level_1_select = $('#region_select_level_1');
        
        level_1_select.empty();

        for (var i = 0, l = level_1_options.length; i < l; i++) {
          var $el = $(document.createElement('option'));
          var option = level_1_options[i];

          $el.attr('value', option.id);
          $el.append(document.createTextNode(option.name));
          level_1_select.append($el);
        }
      
        if (level_1_options.length > 1) {
          $('div.level_1').show();
        } else {
          $('div.level_1').hide();
        }

        $('div.level_2').hide();
        $('div.level_3').hide();

        $('.chzn-container#region_select_level_1_chzn').remove();

        $('#region_select_level_1').change(region_select_level_1_onchange);
        level_1_select.chosen();
      });
    }

    var region_select_level_1_onchange = function (ev) {
      selected_region_ids[1] = ev.target.value;
      selected_region_names[1] = ev.target[ev.target.selectedIndex].text;

      resetRegionLevel(2);
      resetRegionLevel(3);

      if (selected_region_ids[1] === '0') {
        $('div.level_2').hide();
        $('div.level_3').hide();
        return;
      }      

      $.getJSON('/geo/regions/2/' + selected_region_ids[1] + '/json', function (json) {
        var level_2_options = json;
        level_2_options.unshift({ name: "All", id: 0 });

        $('select#region_select_level_2').replaceWith(region_select_level_2_original.clone()[0]);
        var level_2_select = $('#region_select_level_2');

        level_2_select.empty();

        for (var i = 0, l = level_2_options.length; i < l; i++) {
          var $el = $(document.createElement('option'));
          var option = level_2_options[i];

          $el.attr('value', option.id);
          $el.append(document.createTextNode(option.name));
          level_2_select.append($el);
        }

        if (level_2_options.length > 1) {
          $('div.level_2').show();
        } else {
          $('div.level_2').hide();
        }

        $('div.level_3').hide();

        $('.chzn-container#region_select_level_2_chzn').remove();

        $('#region_select_level_2').change(region_select_level_2_onchange);
        level_2_select.chosen();
      });
    }

    var region_select_level_2_onchange = function (ev) {
      selected_region_ids[2] = ev.target.value;
      selected_region_names[2] = ev.target[ev.target.selectedIndex].text;

      resetRegionLevel(3);
      
      if (selected_region_ids[2] === '0') {
        $('div.level_3').hide();
        return;
      }

      $.getJSON('/geo/regions/3/' + selected_region_ids[2] + '/json', function (json) {
        var level_3_options = json;
        level_3_options.unshift({ name: "All", id: 0 });

        $('select#region_select_level_3').replaceWith(region_select_level_3_original.clone()[0]);
        var level_3_select = $('#region_select_level_3');

        level_3_select.empty();

        for (var i = 0, l = level_3_options.length; i < l; i++) {
          var $el = $(document.createElement('option'));
          var option = level_3_options[i];

          $el.attr('value', option.id);
          $el.append(document.createTextNode(option.name));
          level_3_select.append($el);
        }

        if (level_3_options.length > 1) {
          $('div.level_3').show();
        } else {
          $('div.level_3').hide();
        }

        $('.chzn-container#region_select_level_3_chzn').remove();

        $('#region_select_level_3').change(region_select_level_3_onchange);
        level_3_select.chosen();
      });
    }

    var region_select_level_3_onchange = function (ev) {
      selected_region_ids[3] = ev.target.value;
      selected_region_names[3] = ev.target[ev.target.selectedIndex].text;
    }

    $('a#add_region_map').click(function(ev){
      $('#region_select_level_0').change(region_select_level_0_onchange);

      $.getJSON('/geo/countries/json', function (json) {
        level_0_options = json;
        level_0_options.unshift({ name: "All", id: 0 });
        
        var level_0_select = $('select#region_select_level_0');
        
        for (var i = 0, l = level_0_options.length; i < l; i++) {
          var $el = $(document.createElement('option'));
          var option = level_0_options[i];
          
          $el.attr('value', option.id);
          $el.append(document.createTextNode(option.name));
          level_0_select.append($el);
        }
        
        level_0_select.chosen();
      });
      
      ev.preventDefault();
      ev.stopPropagation();
      $('div.region_window').fadeIn();
    });


    $('div.region_window a.close').click(function(ev){
      ev.preventDefault();
      ev.stopPropagation();

      $('div.region_window').fadeOut(function(ev){
        resetRegionValues();
      });
    });

    $('a#add_region_to_list').click(function (e){
      if (selected_region_ids[0] !== '0') {
        var breadcrumb = [];
        for(var i = 0; i < selected_region_names.length; i++) {
          if (selected_region_ids[i] === '0' || 
              selected_region_ids[i] === null ||
              typeof selected_region_ids[i] === 'undefined') {
            selected_region_ids.length = i;
            break;
          }

          breadcrumb.push(selected_region_names[i]);
        }

        var country_id = selected_region_ids[0];
        var region_ids = selected_region_ids.slice(1, selected_region_ids.length);

        if (region_ids.length === 0) {
          $('#regions_list').append(
            '<li data-country-id="'+country_id+'">'+
              '<p>'+breadcrumb.join(' > ')+'</p>'+
              '<input type="hidden" name="project[regions_ids][]" value="country_'+country_id+'" />'+
              '<a href="javascript:void(null)" class="close"></a>'+
            '</li>');

        } else {
          $('#regions_list').append(
            '<li data-country-id="'+country_id+'">'+
              '<p>'+breadcrumb.join(' > ')+'</p>'+
              '<input type="hidden" name="project[regions_ids][]" value="region_'+region_ids[region_ids.length-1]+'" />'+
              '<a href="javascript:void(null)" class="close"></a>'+
            '</li>');
        }
      }
      
      e.preventDefault();
      e.stopPropagation();

      $('div.region_window').fadeOut(function () {
        resetRegionValues();
      });      
    })
    
  });
