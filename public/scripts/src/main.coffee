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

modulus = (a, b) ->
  ((a % b) + b) % b

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
  images = $('#subject-images img')
  images.css 'z-index', ''
  images.eq(index).css 'z-index', 1

  buttons = $('#switch-image button[name="select-image"]')
  buttons.removeClass 'active'
  buttons.eq(index).addClass 'active'

# Copied from subject_viewer.coffee
play = ->
  imageCount = $('#subject-images img').length

  # Flip the images back and forth a couple times.
  last = imageCount - 1
  iterator = [0...last].concat [last...0]
  iterator = iterator.concat [0...last].concat [last...0]

  # End half way through.
  iterator = iterator.concat [0...Math.floor(imageCount / 2) + 1]

  for index, i in iterator then do (index, i) =>
    setTimeout (=> showImage index), i * 333

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

  $('#discuss-link').attr 'href', "#{ talkHref subject }"
  $('#twitter-link').attr 'href', "#{ twitterHref subject }"
  $('#facebook-link').attr 'href', "#{ facebookHref subject }"
  $('#pinterest-link').attr 'href', "#{ pinterestHref subject }"
  $('#tumblr-link').attr 'href', "#{ tumblrHref subject }"

groupList = $('#group-list')
subjectList = $('#subject-list')

allSubjects = null
groupedSubjects = {}
currentSubject = null

selectGroup = (group) ->
  groupList.val group unless groupList.val() is group

  subjectList.empty()
  for subject in groupedSubjects[group]
    subjectList.append "<option value='#{allSubjects.indexOf subject}'>#{moment(subject.captured_at).format 'MMMM Do YYYY h:mm:ss a'}</option>"

selectSubject = (subject) ->
  currentSubject = subject

  selectGroup group for group, subSubjects of groupedSubjects when subject in subSubjects
  subjectList.val allSubjects.indexOf subject

  renderSubject subject

$ ->
  if location.hash is ""
    $('#app').html 'Need to specify a trap!'
  else
    cameraTrap = location.hash.slice 1

    $('#camera-id').html cameraTrap
    $('#donor-name').html DONORS[cameraTrap]

    request = fetch cameraTrap

    request.done (data) ->
      allSubjects = data.rows

      for subject in allSubjects
        yearMonth = moment(subject.captured_at).format 'YYYY-MMMM'
        groupedSubjects[yearMonth] ?= []
        groupedSubjects[yearMonth].push subject

      for group, subjects of groupedSubjects
        groupList.append "<option value='#{group}'>#{moment(group).format 'MMMM YYYY'}</option>"

      groupList.on 'change', -> selectSubject groupedSubjects[groupList.val()][0]

      subjectList.on 'change', -> selectSubject allSubjects[subjectList.val()]

      selectSubject allSubjects[0]

      $('button[name="play"]').on 'click', play

      $('#switch-image').click 'button', ({ target }) ->
        showImage $(target).val()

      $('#subject-list').change ({ currentTarget }) ->
        currentSubject = parseInt currentTarget.value
        renderSubject data.rows[currentSubject]

      $('#navigation').click 'button', ({ target }) ->
        switch target.name
          when "previous"
            selectSubject allSubjects[modulus allSubjects.indexOf(currentSubject) - 1, allSubjects.length]
          when "next"
            selectSubject allSubjects[modulus allSubjects.indexOf(currentSubject) + 1, allSubjects.length]
