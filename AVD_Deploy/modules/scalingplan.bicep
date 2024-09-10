@description('Name of scalingplan')
param name string

@description('Region of scalingplan')
param location string = resourceGroup().location

@description('Tags of the scalingplan')
param tags object

@description('Exclusion Tag for exclusing session hosts from the scalingplan')
param exclusionTag string

@description('Friendly name of the scalingplan')
param friendlyNameSC string

@description('Hostpool ID: Needed for applying to the right hostpool')
param hostPoolId string

@description('Scaling plan Hostpool type')
param hostPoolType string

@description('Name of scedule')
param nameSchedule string

@description('ScalingPlan Enabled or not')
param scalingPlanEnabled bool

@description('Rampdown Notification for users to log off')
param rampDownNotificationMessage string


resource scalingplan 'Microsoft.DesktopVirtualization/scalingPlans@2024-01-16-preview' = {
  name: 'scpl-${name}'
  location: location
  tags: tags
  properties: {
    exclusionTag: exclusionTag
    friendlyName: friendlyNameSC
    hostPoolReferences: [
      {
        hostPoolArmPath: hostPoolId
        scalingPlanEnabled: scalingPlanEnabled
      }
    ]
    hostPoolType: hostPoolType
    schedules: [
      {
        daysOfWeek: [
          'Monday'
          'Tuesday'
          'Wednesday'
          'Thursday'
          'Friday'
        ]
        name: nameSchedule
        offPeakLoadBalancingAlgorithm: 'DepthFirst'
        offPeakStartTime: {
          hour: 19
          minute: 0
        }
        peakLoadBalancingAlgorithm: 'BreadthFirst'
        peakStartTime: {
          hour: 8
          minute: 0
        }
        rampDownCapacityThresholdPct: 50
        rampDownForceLogoffUsers: true
        rampDownLoadBalancingAlgorithm: 'DepthFirst'
        rampDownMinimumHostsPct: 50
        rampDownNotificationMessage: rampDownNotificationMessage
        rampDownStartTime: {
          hour: 18
          minute: 0
        }
        rampDownStopHostsWhen: 'ZeroSessions'
        rampDownWaitTimeMinutes: 30
        rampUpCapacityThresholdPct: 80
        rampUpLoadBalancingAlgorithm: 'BreadthFirst'
        rampUpMinimumHostsPct: 10
        rampUpStartTime: {
          hour: 7
          minute: 0        
        }
      }
    ]
    timeZone: 'W. Europe Standard Time'
  }

}
