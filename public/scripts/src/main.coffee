fetch = (trap) ->
  baseUrl = "https://the-zooniverse.cartodb.com/api/v2/sql?q="

  # Set base query
  query = "#{ baseUrl }select * from serengeti where site='#{ trap }' order by captured_at limit 3"
  
  # Encode query appropriately
  query = encodeURI(query)
  query = query.replace(/\+/g, '%2B')

  request = $.get "#{ query }"
  request

renderSubject = (subject) ->
  $('#captured_at').html "Captured at: #{ moment(subject.captured_at).format('MMMM Do YYYY, h:mm:ss a') }"
  $('#subject-images').html ""
  $('#switch-image').html ""

  for imgSrc, i in subject.locations
    img = new Image
    img.src = imgSrc
    $('#subject-images').append img
    $('#switch-image').append "<button value=\"#{ i }\">#{ i + 1 }</button>"

  $('#subject-images').children().first().css 'z-index', 1

renderSubjectList = (subjects) ->
  for subject, i in subjects
    $('#subject-list').append "<option value=\"#{ i }\">#{ moment(subject.captured_at).format('MMMM Do YYYY, h:mm:ss a') }</option>"

updateSubjectList = (i) ->
  $('#subject-list option:selected').removeAttr 'selected'
  $("#subject-list option:nth-child(#{ i + 1 })").attr 'selected', 'selected'

$ ->
  if location.hash is ""
    $('#app').html 'Need to specify a trap!'
  else
    cameraTrap = location.hash.slice 1

    request = fetch cameraTrap

    request.done (data) ->
      if data.rows.length
        currentSubject = 0

        renderSubject data.rows[currentSubject]
        renderSubjectList data.rows

        $('#subject-list').change ({ currentTarget }) ->
          currentSubject = parseInt currentTarget.value
          renderSubject data.rows[currentSubject]

        $('#switch-image').click 'button', ({ target }) ->
          $('#subject-images').children().css 'z-index', 0
          $('#subject-images').children(":nth-child(#{ target.value })").css 'z-index', 1

        $('#navigation').click 'button', ({ target }) ->
          switch target.name
            when "previous"
              if currentSubject is 0
                currentSubject = data.rows.length - 1
              else
                currentSubject -= 1
            when "next"
              if currentSubject is (data.rows.length - 1)
                currentSubject = 0
              else
                currentSubject += 1

          renderSubject data.rows[currentSubject]
          updateSubjectList currentSubject







