function onCourseChange(e) {
  var course_id = course_select.val();

  $('input[type="submit"]').hide();

  $.get("/courses/" + course_id + ".json",
    function(data){
      var tickets = data["tickets"]
      ticket_select.empty()

      console.log("tickets", tickets);
      for(var key in tickets) {
        ticket = tickets[key];
        ticket_select.append('<option value="'+ticket["id"]+'">'+ticket["label"]+'</option>')
      }

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

course_select.change(onCourseChange);
onCourseChange()
