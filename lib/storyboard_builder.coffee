$( ->
  window.storyView = new StoryboardBuilder
)

class StoryboardBuilder extends Backbone.View
  el: '.story'
  storyLength: null
  
  events:
    "click .prev": (e) -> 
      e.preventDefault()
      @.previous()
    "click .next": (e) ->
      e.preventDefault()
      @.next()
  
  initialize: (options) ->
    @render()
    # grid = new data_grid.DataGrid("data_grid")
    
    # RAW STORY HERE ****** ######
    story = 
      scene0:
        content: 'Lorem Upsum dolor sit amet, consectetur apdd elit, sed so tempor to the max.  Lorem Upsum dolor sit amet, consectetur apdd elit, sed so tempor to the max.'
        dimensions: ["Acquirer Region", "Target Region"]
    
      scene1:
        content: 'Dalor ipsumtat lo?  Lorem Upsum dolor sit amet, consectetur apdd elit, sed so tempor to the max.'
        dimensions: ["Acquirer Region", "Target Region"]
        filters: { 'Acquirer Region': ['North America', 'Asia-Pacific'] }
    
      scene2:
        content: 'Lorem Upsum dolor sit amet, consectetur apdd elit, sed so tempor to the max.'
        dimensions: ["Acquirer Country", "Target Region"]
        filters: { 'Acquirer Country': ['US', 'CH'] }
      
    d3.json("../stories/5161d044d952c038a1000002/api.json", (storyJson) =>
      d3.csv("../data/ma.csv", (csv) =>
        @data = csv
        @buildStory(storyJson)
        # grid.show(csv)
      )
    )
    
  render: ->
    $('.article').html JST['story']
    @
  	
  buildStory: (rawScenes) ->
    
    # add enter callback
    for key, value of rawScenes
      rawScenes[key].enter = ->
        @parent.draw @
    
    @story = new Miso.Storyboard(
      initial: 'scene0'
      data: @data
      
      draw: (scene) ->
        $('.chapter').removeClass('active')
        $(".chapter.#{scene.name}").addClass('active')
        $('.extended-content p').html scene.content
        $('#vis').empty()
        
        # filter
        data = _.filter(scene.parent.data, (d) ->
          for key, value of scene.filters
            return false unless d[key] in value
          return true
        )
        
        width = $("#vis").width()
        height = $("#vis").height()
        chart = d3.parsets().dimensions(scene.dimensions)
        vis = d3.select("#vis").append("svg").attr("width", width).attr("height", height)
        vis.datum(data).call(chart.width(width).height(height))
        
      scenes: rawScenes
          
    )
    @storyLength = Object.keys(@story.scenes).length
    i = 0
    for key, value of @story.scenes
      @$('.chapters').append "<div class='chapter #{key}'><h1>#{i + 1}</h1><p>#{value.content}</p></div>"
      i++
    @story.start()
    
  next: ->
    i = @story.scene().toString().substring(@story.scene().toString().length - 1, @story.scene().toString().length)
    i++ unless i >= @storyLength - 1
    @story.to("scene#{i}")
    
  previous: ->
    i = @story.scene().toString().substring(@story.scene().toString().length - 1, @story.scene().toString().length)
    if i < 1
      i = 0
    else
      i--
    @story.to("scene#{i}")
