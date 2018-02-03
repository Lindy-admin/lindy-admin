var HOST = "";

function populateCourses(course_select) {
  $.get(HOST + "/courses.json",
    function(data) {
      course_select.empty();
      $.each(data, function() {
       course = this;
       course_select.append('<option value="'+course["id"]+'">'+course["title"]+'</option>')
      });

      onCourseChange();
    }
  ).fail(
    function(error){
      console.error("Could not fetch courses data", error);
    }
  )
}

function onCourseChange(e) {
  var course_id = course_select.val();

  $('input[type="submit"]').hide();

  $.get(HOST + "/courses/" + course_id + ".json",
    function(data){
      ticket_select.empty()

      $.each(data["tickets"], function() {
        ticket = this;
        ticket_select.append('<option value="'+ticket["id"]+'">'+ticket["label"]+'</option>')
      });

      $('input[type="submit"]').show();
    }
  ).fail(
    function(error){
      console.error("Could not fetch ticket data", error);
    }
  )
}

var course_select = $("select#course");
var ticket_select = $("select#ticket");

$('input[type="submit"]').hide();
course_select.change(onCourseChange);
populateCourses(course_select);
