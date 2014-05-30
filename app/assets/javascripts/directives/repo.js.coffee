App.directive 'repo', ['$modal', ($modal) ->
  scope: true

  templateUrl: '/templates/repo'

  link: (scope, element, attributes) ->
    repo = scope.repo
    scope.processing = false

    activate = ->
      if repo.private
        $modal.open(
          templateUrl: '/templates/payment_modal'
          controller: 'PaymentModal'
          scope: scope
        )

      repo.$activate()
        .then(-> scope.processing = false)
        .catch(-> alert('Your repo failed to activate.'))

    deactivate = ->
      repo.$deactivate()
        .then(-> scope.processing = false)
        .catch(-> alert('Your repo failed to deactivate.'))

    scope.toggle = ->
      scope.processing = true

      if repo.active
        deactivate(repo)
      else
        activate(repo)
]
