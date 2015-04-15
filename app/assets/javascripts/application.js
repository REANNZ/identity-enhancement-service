//= require jquery
//= require jquery_ujs
//= require semantic-ui
//= require pickadate
//= require aaf-layout

jQuery(function($) {
  $('.popup').popup({ inline: true, position: 'right center' });

  $('.help.button').popup({
    position : 'top center',
    hoverable: true,
    delay: {
      hide: 150
    }
  });

  $.fn.form.settings.rules['urlsafe_base64'] = function(value) {
    return value == '' || value.match(/^[\w-]*$/);
  };

  $.fn.form.settings.rules['attribute_name'] = function(value) {
    return value == '' || value == 'eduPersonEntitlement';
  };

  $.fn.form.settings.rules['attribute_value'] = function(value) {
    return value == '' ||
      value.match(/^urn:mace:aaf\.edu\.au:ide:([\w\.-]+:)*[\w\.-]+$/);
  };

  $.fn.form.settings.rules['accession_permission_value'] = function(value) {
    return value == '' || value.match(/^(([\w\.-]+|\*):)*([\w\.-]+|\*)$/);
  };


  $.fn.form.settings.rules['future_date'] = function(value) {
    if (value == '') return true;
    var now = new Date().getTime();
    return (now < Date.parse(value));
  };
});
