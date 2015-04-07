$(function() {
  $( "#sortable" ).sortable();
  $( "#sortable" ).disableSelection();
  $( "#edit_article_submit" ).click(function() {
    $( "#article_section_order" ).val( $( "#sortable" ).sortable( "toArray" ).join() );
    $( "form" ).submit();
  });
  $( "#edit_section_submit" ).click(function() {
    $( "#section_note_order" ).val( $( "#sortable" ).sortable( "toArray" ).join() );
    $( "form" ).submit();
  });
});

