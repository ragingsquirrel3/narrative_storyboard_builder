class DataGrid extends Backbone.View
  el: '.data-grid'
  
  filters: null
  sortField: null
  limit: 25
  offset: 0
  activePage: 0
  
  events: 
    "click .descending": (e) -> @.sortBy(e)
    "click .ascending": (e) -> @.sortBy(e, true)
    "click .to-page": 'toPage'
  
  initialize: (options) ->
    @limit = options.limit if options.limit
    @data = options.data
    @render()
    
  render: () ->
    $('.data-grid').html JST['data_grid'] data: @data.slice(@offset * @limit, @offset * @limit + @limit), paginateLength: if @data.length / @limit < 11 then Math.round(@data.length / @limit) else 11
    @$('.to-page').removeClass('active')
    @$(".to-page.page-#{@offset}").addClass('active')
    @
    
  sortBy: (e, ascending = false) ->
    e.preventDefault()
    key = @$(e.currentTarget).data().key
    @data = _.sortBy(@data, (o) ->
      return o[key]
    )
    @data = @data.reverse() unless ascending
    @render()
    
  toPage: (e) ->
    e.preventDefault()
    @offset = @$(e.currentTarget).data().offset
    @render()
