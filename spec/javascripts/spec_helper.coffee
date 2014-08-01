#= require application
#= require angular-mocks

beforeEach(module('App'))

beforeEach inject ($rootScope, _$httpBackend_, $controller) ->
  @scope = $rootScope.$new()
  @http = _$httpBackend_
  @controller = $controller

afterEach ->
  @http.resetExpectations()
  @http.verifyNoOutstandingExpectation()
