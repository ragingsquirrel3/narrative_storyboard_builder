class StoryboardBuilder extends Backbone.View
  el: '.article'
  storyLength: null
  
  events:
    "click .show-data": "showData"
    "click .prev": (e) -> 
      e.preventDefault()
      @.previous()
    "click .next": (e) ->
      e.preventDefault()
      @.next()
  
  initialize: (options) ->
    @render()
     
    d3.json("../data/story.json", (storyJson) =>
      d3.csv("../data/ma.csv", (csv) =>
        @data = csv
        @buildStory(storyJson)
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
    
    # subscribe to first and last scenes to disable/renable buttons
    @story.subscribe('scene0:enter', =>
      @$('.prev').addClass('disabled')
    )
    @story.subscribe('scene0:exit', =>
      @$('.prev').removeClass('disabled')
    )
    @story.subscribe("scene#{@storyLength - 1}:enter", =>
      @$('.next').addClass('disabled')
    )
    @story.subscribe("scene#{@storyLength - 1}:exit", =>
      @$('.next').removeClass('disabled')
    )
    @story.start()
    
  next: ->
    i = @story.scene().toString().substring(@story.scene().toString().length - 1, @story.scene().toString().length)
    i++ unless i >= @storyLength - 1
    @story.to("scene#{i}")
    
  previous: ->
    i = @story.scene().toString().substring(@story.scene().toString().length - 1, @story.scene().toString().length)
    i-- unless i < 1
    @story.to("scene#{i}")
    
  showData: (e) ->
    e.preventDefault()
    @grid = new DataGrid data: @data
