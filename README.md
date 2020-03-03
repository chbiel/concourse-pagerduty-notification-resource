# concourse-pagerduty-notificaton-resource

Send events to PagerDuty Events API v2.

## Source Configuration

* `debug`: *Optional.* Set to any value to enable debug logging. Use with caution as sensitive data will be logged!

## Behavior

### `out`: Sends alert to PagerDuty.

Send alert to PagerDuty with the configured parameters.

#### Parameters

Basically all parameters from https://v2.developer.pagerduty.com/v2/docs/send-an-event-events-api-v2 are allowed.

The parameters are added as flat map items (so don't create a "payload" sub-map).

Additionally the following parameters can be set:

* `generate_dedub_key`: *Optional.* Set to any value to enable generation of `dedup_key` parameter. 
The value will be set to `BUILD_PIPELINE_NAME + _ + BUILD_JOB_NAME`.

* `event_action`: *Required.* Worth to mention as this parameter will be used to determine which kind of event will be send to the PagerDuty API.

## Example

```
resource_types:
- name: pagerduty-notification
  type: docker-image
  source:
    repository: chbiel/concourse-pagerduty-notification-resource
    tag: latest

resources:
- name: pd-alarm
  type: pagerduty-notification
  source:
    debug: true

jobs:
- name: teams-notification
  serial: true
  on_failure:
    do:
    - put: pd-alarm
      params:
        routing_key: 'integration_key',
        event_action: 'trigger',
        summary: 'my cool alarm'
        source: 'some test resource',
        severity: 'error
        custom_details:
            something: 'anything'

  plan:
  - task: fail
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: alpine
      run:
        path: sh
        args:
        - -exc
        - |
          exit 1
```