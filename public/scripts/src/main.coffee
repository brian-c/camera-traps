DONORS =
  'E06': 'Rafael P. Bedia'
  'F05': 'McCrea family'
  'F06': 'Turner Glynn'
  'F12': 'El_Lion'
  'G03': 'Libby Kerr'
  'G04': 'Adam Wolkon'
  'G05': 'Kristine and Bart'
  'H05': 'the Anderson Family'
  'H06': 'Kevin Boyd'
  'S09': 'Lorrne Gates'
  'I04': 'Bushtracks Expeditions (Bushtracks.com)'
  'O06': 'Hannelore Schmidt'
  'S09': 'Daniela F. Sieff'

fetch = (trap) ->
  baseUrl = "https://the-zooniverse.cartodb.com/api/v2/sql?q="

  # Set base query
  query = "#{ baseUrl }select * from serengeti where site='#{ trap }' order by captured_at"

  # Encode query appropriately
  query = encodeURI(query)
  query = query.replace(/\+/g, '%2B')

  request = $.get "#{ query }"
  request

showImage = (index) ->
  $('#subject-images').children().css 'z-index', ''
  $('#subject-images').children().eq(index).css 'z-index', 1

talkHref = (subject) ->
  "http://talk.snapshotserengeti.org/#/subjects/#{subject.subject_id}"

facebookHref = (subject) ->
  title = 'Snapshot Serengeti'
  summary = 'Here\'s an image from my camera trap'
  image = $("<a href='#{subject.locations[0]}'></a>").get(0).href
  """
    https://www.facebook.com/sharer/sharer.php
    ?s=100
    &p[url]=#{ encodeURIComponent talkHref arguments... }
    &p[title]=#{ encodeURIComponent title }
    &p[summary]=#{ encodeURIComponent summary }
    &p[images][0]=#{image}
  """.replace /\n/g, ''

twitterHref = (subject) ->
  message = "An image from my @snapserengeti camera trap: #{ talkHref arguments... }"
  "http://twitter.com/home?status=#{ encodeURIComponent message} "

pinterestHref = (subject) ->
  image = $("<a href='#{subject.locations[0]}'></a>").get(0).href
  summary = 'An image from my Snapshot Serengeti camera trap'
  """
    http://pinterest.com/pin/create/button/
    ?url=#{ encodeURIComponent talkHref arguments... }
    &media=#{ encodeURIComponent image }
    &description=#{ encodeURIComponent summary }
  """.replace /\n/g, ''

# NOTE: This should work. It does not. I do not know why.
tumblrHref = (subject) ->
  """
    http://www.tumblr.com/share/photo
    &source=#{ encodeURIComponent subject.locations[0] }
    &caption=#{ encodeURIComponent 'An image from my Snapshot Serengeti camera trap' }
    &clickthru=#{ encodeURIComponent talkHref arguments... }
  """.replace /\n/g, ''

renderSubject = (subject) ->
  $('#captured_at').html "Captured at: #{ moment(subject.captured_at).format('MMMM Do YYYY, h:mm:ss a') }"
  $('#subject-images').html ""
  $('#switch-image').html ""

  for imgSrc, i in subject.locations
    img = new Image
    img.src = imgSrc
    $('#subject-images').append img
    $('#switch-image').append "<button name=\"select-image\" value=\"#{ i }\">#{ i + 1 }</button>"

  showImage 0

  $('#twitter-link').attr 'href', "#{ twitterHref subject }"
  $('#facebook-link').attr 'href', "#{ facebookHref subject }"
  $('#pinterest-link').attr 'href', "#{ pinterestHref subject }"
  $('#tumblr-link').attr 'href', "#{ tumblrHref subject }"

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

    $('#camera-id').html cameraTrap
    $('#donor-name').html DONORS[cameraTrap]

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
          showImage $(target).val()

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
