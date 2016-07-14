$.fn.load_user_calendar = () ->
  $popup = $ '.user-calendar__add-popup'

  this.fullCalendar
    events: this.attr 'data-calendar'  # load events from JSON
    dayClick: (date, jsEvent, view) ->
      # store clicked date, to load it after popup appears
      $(this).parents('.user-calendar').data 'clickedDay', date
      $popup.load $popup.attr('data-src'), null, popupLoaded
      $popup.css
        display: 'block'
        top: jsEvent.pageY,
        left: jsEvent.pageX

# TODO — escape and click outside a popup should close the popup

popupLoaded = () ->
  $('.timeline-entry-form form').each () ->
    $form        = $ this
    $lesson_type = $ '#id_lesson_type', $form
    $lesson      = $ '#id_lesson_id', $form
    $duration    = $ '#id_duration', $form
    $time        = $ '#id_start_time_1', $form
    $date        = $ '#id_start_time_0', $form
    $calendar    = $ '.user-calendar'

    $date.val $calendar.data('clickedDay').format 'L'
    $date.applyDatePicker()

    $time.applyTimepicker()

    $duration.applyDurationSelector()


    # update lesson selector
    $lesson_type.on 'change', () ->
      lessons = $form.attr 'data-lessons'
      lessons += "?lesson_id=" + $(this).val()

      $.getJSON lessons, (data) ->
        $lesson.html ''
        $lesson.append \
          sprintf '<option value="%d" data-duration="%s">%s</option>', \
          lesson.id, lesson.duration, lesson.name \
            for lesson in data
        $lesson.change()  # trigger update of a default duration


      # set default duration of a selected lesson
      $lesson.on 'change', () ->
        option = $ 'option:selected', this
        $duration.val option.attr 'data-duration'
        $duration.change()

    # some prettyness
    # i need to use JS here, because to customize Django's SplitDateTimeField
    # i would have to break my brain subclassing it
    $time.attr 'placeholder', 'HH:MM'
    $time.attr 'maxlength', 5
    $time.attr 'required', true

    $duration.attr 'required', true

    $lesson_type.attr 'required', true
    $lesson.attr 'required', true

    $('option:first-child', $lesson_type).text('Choose lesson type')


$(document).ready ->
  $('.user-calendar').load_user_calendar()