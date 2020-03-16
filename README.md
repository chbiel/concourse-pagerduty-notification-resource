# concourse-pagerduty-notification-resource

Send events to PagerDuty Events API v2.

Docker Hub: https://hub.docker.com/r/chbiel/concourse-pagerduty-notification-resource

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

* `routing_key`: *Required.* Worth to mention as this is the integration key from PagerDuty which is somd kind of a secret and should be treated like this.

* `event_action`: *Required.* Worth to mention as this parameter will be used to determine which kind of event will be send to the PagerDuty API.
    * `trigger`: will trigger an alarm
    * `acknowledge`: will acknowledge an alarm by dedup_key
    * `resolve`: will resolve an alarm by dedup_key

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
- name: failing
  serial: true
  on_failure:
    put: pd-alarm
    params:
      generate_dedub_key: true
      routing_key: secret_integration_key
      event_action: trigger
      summary: 'my cool alarm'
      source: 'some test resource'
      severity: error
      custom_details:
        something: 'anything'
  on_success:
    put: pd-alarm
    params:
      generate_dedub_key: true
      routing_key: secret_integration_key
      event_action: resolve

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