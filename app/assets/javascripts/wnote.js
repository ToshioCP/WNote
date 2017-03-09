$(function() {
  $( "#sortable" ).sortable();
  $( "form.edit_article" ).submit(function() {
    $( "input#article_section_order" ).val( $( "#sortable" ).sortable( "toArray" ).join( "," ) );
    return true;
  });
  $( "form.edit_section" ).submit(function() {
    $( "input#section_note_order" ).val( $( "#sortable" ).sortable( "toArray" ).join( "," ) );
    return true;
  });
});

