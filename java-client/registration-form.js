var course_select = $("select#course");
var ticket_select = $("select#ticket");

function loadCourses() {
  course_select.empty();

  $.get("https://admin.dev/courses/open.json",
    function(data){
      $.courses = data
      course_select.empty()

      console.log("courses", data);
      $.each(data, function(index, course){
        console.log("course", course)
        course_select.append('<option value="'+course["id"]+'">'+course["title"]+'</option>')
      });
      $(course_select)[0].selectedIndex = 0;
      onCourseChange(null)
    }
  ).fail(
    function(error){
      console.error("Could not fetch open courses", error);
      // TODO show error
    }
  )
}

function onCourseChange(e) {
  $('input[type="submit"]').hide();

  var course_id = course_select.val();

  $.each($.courses, function(index, course){
    if(course["id"] == course_id){
      setCourse(course);
    }
  });

  $('input[type="submit"]').show();
}

function setCourse(course){
  tickets = course["tickets"];

  ticket_select.empty()
  $.each(tickets, function(index, ticket){
    ticket_select.append('<option value="'+ticket["id"]+'">'+ticket["label"]+'</option>')
  });
}

course_select.change(onCourseChange);
loadCourses();
