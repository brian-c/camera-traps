// Generated by CoffeeScript 1.6.3
(function() {
  var DONORS, facebookHref, fetch, pinterestHref, play, renderSubject, renderSubjectList, showImage, talkHref, tumblrHref, twitterHref, updateSubjectList;

  DONORS = {
    'E06': 'Rafael P. Bedia',
    'F05': 'McCrea family',
    'F06': 'Turner Glynn',
    'F12': 'El_Lion',
    'G03': 'Libby Kerr',
    'G04': 'Adam Wolkon',
    'G05': 'Kristine and Bart',
    'H05': 'the Anderson Family',
    'H06': 'Kevin Boyd',
    'S09': 'Lorrne Gates',
    'I04': 'Bushtracks Expeditions (Bushtracks.com)',
    'O06': 'Hannelore Schmidt',
    'S09': 'Daniela F. Sieff'
  };

  fetch = function(trap) {
    var baseUrl, query, request;
    baseUrl = "https://the-zooniverse.cartodb.com/api/v2/sql?q=";
    query = "" + baseUrl + "select * from serengeti where site='" + trap + "' order by captured_at";
    query = encodeURI(query);
    query = query.replace(/\+/g, '%2B');
    request = $.get("" + query);
    return request;
  };

  showImage = function(index) {
    var buttons, images;
    images = $('#subject-images img');
    images.css('z-index', '');
    images.eq(index).css('z-index', 1);
    buttons = $('#switch-image button[name="select-image"]');
    buttons.removeClass('active');
    return buttons.eq(index).addClass('active');
  };

  play = function() {
    var i, imageCount, index, iterator, last, _i, _j, _k, _l, _len, _m, _n, _ref, _results, _results1, _results2, _results3, _results4, _results5,
      _this = this;
    imageCount = $('#subject-images img').length;
    last = imageCount - 1;
    iterator = (function() {
      _results1 = [];
      for (var _j = 0; 0 <= last ? _j < last : _j > last; 0 <= last ? _j++ : _j--){ _results1.push(_j); }
      return _results1;
    }).apply(this).concat((function() {
      _results = [];
      for (var _i = last; last <= 0 ? _i < 0 : _i > 0; last <= 0 ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this));
    iterator = iterator.concat((function() {
      _results3 = [];
      for (var _l = 0; 0 <= last ? _l < last : _l > last; 0 <= last ? _l++ : _l--){ _results3.push(_l); }
      return _results3;
    }).apply(this).concat((function() {
      _results2 = [];
      for (var _k = last; last <= 0 ? _k < 0 : _k > 0; last <= 0 ? _k++ : _k--){ _results2.push(_k); }
      return _results2;
    }).apply(this)));
    iterator = iterator.concat((function() {
      _results4 = [];
      for (var _m = 0, _ref = Math.floor(imageCount / 2) + 1; 0 <= _ref ? _m < _ref : _m > _ref; 0 <= _ref ? _m++ : _m--){ _results4.push(_m); }
      return _results4;
    }).apply(this));
    _results5 = [];
    for (i = _n = 0, _len = iterator.length; _n < _len; i = ++_n) {
      index = iterator[i];
      _results5.push((function(index, i) {
        return setTimeout((function() {
          return showImage(index);
        }), i * 333);
      })(index, i));
    }
    return _results5;
  };

  talkHref = function(subject) {
    return "http://talk.snapshotserengeti.org/#/subjects/" + subject.subject_id;
  };

  facebookHref = function(subject) {
    var image, summary, title;
    title = 'Snapshot Serengeti';
    summary = 'Here\'s an image from my camera trap';
    image = $("<a href='" + subject.locations[0] + "'></a>").get(0).href;
    return ("https://www.facebook.com/sharer/sharer.php\n?s=100\n&p[url]=" + (encodeURIComponent(talkHref.apply(null, arguments))) + "\n&p[title]=" + (encodeURIComponent(title)) + "\n&p[summary]=" + (encodeURIComponent(summary)) + "\n&p[images][0]=" + image).replace(/\n/g, '');
  };

  twitterHref = function(subject) {
    var message;
    message = "An image from my @snapserengeti camera trap: " + (talkHref.apply(null, arguments));
    return "http://twitter.com/home?status=" + (encodeURIComponent(message)) + " ";
  };

  pinterestHref = function(subject) {
    var image, summary;
    image = $("<a href='" + subject.locations[0] + "'></a>").get(0).href;
    summary = 'An image from my Snapshot Serengeti camera trap';
    return ("http://pinterest.com/pin/create/button/\n?url=" + (encodeURIComponent(talkHref.apply(null, arguments))) + "\n&media=" + (encodeURIComponent(image)) + "\n&description=" + (encodeURIComponent(summary))).replace(/\n/g, '');
  };

  tumblrHref = function(subject) {
    return ("http://www.tumblr.com/share/photo\n&source=" + (encodeURIComponent(subject.locations[0])) + "\n&caption=" + (encodeURIComponent('An image from my Snapshot Serengeti camera trap')) + "\n&clickthru=" + (encodeURIComponent(talkHref.apply(null, arguments)))).replace(/\n/g, '');
  };

  renderSubject = function(subject) {
    var i, img, imgSrc, _i, _len, _ref;
    $('#captured_at').html("Captured at: " + (moment(subject.captured_at).format('MMMM Do YYYY, h:mm:ss a')));
    $('#subject-images').html("");
    $('#switch-image').html("");
    _ref = subject.locations;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      imgSrc = _ref[i];
      img = new Image;
      img.src = imgSrc;
      $('#subject-images').append(img);
      $('#switch-image').append("<button name=\"select-image\" value=\"" + i + "\">" + (i + 1) + "</button>");
    }
    showImage(0);
    $('#discuss-link').attr('href', "" + (talkHref(subject)));
    $('#twitter-link').attr('href', "" + (twitterHref(subject)));
    $('#facebook-link').attr('href', "" + (facebookHref(subject)));
    $('#pinterest-link').attr('href', "" + (pinterestHref(subject)));
    return $('#tumblr-link').attr('href', "" + (tumblrHref(subject)));
  };

  renderSubjectList = function(subjects) {
    var i, subject, _i, _len, _results;
    _results = [];
    for (i = _i = 0, _len = subjects.length; _i < _len; i = ++_i) {
      subject = subjects[i];
      _results.push($('#subject-list').append("<option value=\"" + i + "\">" + (moment(subject.captured_at).format('MMMM Do YYYY, h:mm:ss a')) + "</option>"));
    }
    return _results;
  };

  updateSubjectList = function(i) {
    $('#subject-list option:selected').removeAttr('selected');
    return $("#subject-list option:nth-child(" + (i + 1) + ")").attr('selected', 'selected');
  };

  $(function() {
    var cameraTrap, request;
    if (location.hash === "") {
      return $('#app').html('Need to specify a trap!');
    } else {
      cameraTrap = location.hash.slice(1);
      $('#camera-id').html(cameraTrap);
      $('#donor-name').html(DONORS[cameraTrap]);
      request = fetch(cameraTrap);
      return request.done(function(data) {
        var currentSubject;
        if (data.rows.length) {
          currentSubject = 0;
          renderSubject(data.rows[currentSubject]);
          renderSubjectList(data.rows);
          $('button[name="play"]').on('click', play);
          $('#switch-image').click('button', function(_arg) {
            var target;
            target = _arg.target;
            return showImage($(target).val());
          });
          $('#subject-list').change(function(_arg) {
            var currentTarget;
            currentTarget = _arg.currentTarget;
            currentSubject = parseInt(currentTarget.value);
            return renderSubject(data.rows[currentSubject]);
          });
          return $('#navigation').click('button', function(_arg) {
            var target;
            target = _arg.target;
            switch (target.name) {
              case "previous":
                if (currentSubject === 0) {
                  currentSubject = data.rows.length - 1;
                } else {
                  currentSubject -= 1;
                }
                break;
              case "next":
                if (currentSubject === (data.rows.length - 1)) {
                  currentSubject = 0;
                } else {
                  currentSubject += 1;
                }
            }
            renderSubject(data.rows[currentSubject]);
            return updateSubjectList(currentSubject);
          });
        }
      });
    }
  });

}).call(this);
