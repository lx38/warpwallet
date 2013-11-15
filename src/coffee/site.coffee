

class Warper

  constructor: ->
    @attach_ux()

  const: ->
    OLDEST_DATE: new Date(1900,0,1)

  attach_ux: ->
    $('#btn-submit').on 'click',            => @click_submit()
    $('#salt').on       'change',           => @salt_change()
    $('#salt').on       'keyup',            => @salt_change()
    $('#checkbox-salt-confirm').on 'click', => @any_change()
    $('#passphrase').on 'change',           => @any_change()
    $('#passphrase').on 'keyup',            => @any_change()

  any_change: ->
    pp   = $('#passphrase').val()
    salt = $('#salt').val()
    chk  = $('#checkbox-salt-confirm').is ":checked"
    err  = null
    warn = null
    if not pp.length
      err = "Please enter a passphrase"
    else if salt?.length and not chk
      err = "Fix and accept your salt"
    else if pp.length < 12
      warn = "Consider a larger passphrase"

    if err
      $('#btn-submit').attr('disabled', true).html err
    else if warn
      $('#btn-submit').attr('disabled', false).html warn
    else  
      $('#btn-submit').attr('disabled', false).html "Generate"
    $('.output-form').hide()
    $('#public-address').val ''
    $('#private-key').val ''

  salt_change: ->
    salt = $('#salt').val()
    salt = salt.replace(/// [/\.] ///g , '-').replace /// [^0-9\-] ///g , ''
    $('#checkbox-salt-confirm').attr 'checked', false
    $('#salt').val salt
    if not salt.length
      $('.salt-confirm').hide()
    if salt.match /// ^[0-9]{4}-[0-9]{2}-[0-9]{2} $///
      mom = moment salt, "YYYY-MM-DD"
      $('.salt-confirm').show()
      $('.salt-summary').html mom.format "MMMM Do, YYYY"
    else
      $('.salt-confirm').hide()
    @any_change()

  progress_hook: (o) ->
    $(".progress-form").html JSON.stringify o

  click_submit: ->
    $('#btn-submit').attr('disabled', true).html 'Running...'

    $('.progress-form').show()

    d = {}
    (d[k] = v for k,v of window.params)
    console.log d
    d.salt = new warpwallet.WordArray.from_utf8 $('#salt').val()
    d.key  = new warpwallet.WordArray.from_utf8 $('#passphrase').val()
    d.progress_hook = (o) => @progress_hook o

    warpwallet.scrypt d, (words) =>

      $('.output-form').show()
      out = warpwallet.generate words.to_buffer()
      $('#public-address').val out.public
      $('#private-key').val    out.private

$ ->
  new Warper()
