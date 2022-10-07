import getCollectingEvent from './getCollectingEvent'
import getCollectionObject from './getCollectionObject'
import getDepictions from './getDepictions'
import getDwc from './getDwc'
import getGeoreferences from './getGeoreferences'
import getIdentifiers from './getIdentifiers'
import getSoftValidationFor from './getSoftValidationFor'
import getTimeline from './getTimeline'

const GetterNames = {
  GetCollectingEvent: 'getCollectingEvent',
  GetCollectionObject: 'getCollectionObject',
  GetDepictions: 'getDepictions',
  GetDwc: 'getDwc',
  GetGeoreferences: 'loadGeoreferences',
  GetIdentifiers: 'getIdentifiers',
  GetSoftValidationFor: 'getSoftValidationFor',
  GetTimeline: 'getTimeline'
}

const GetterFunctions = {
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetDwc]: getDwc,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetIdentifiers]: getIdentifiers,
  [GetterNames.GetSoftValidationFor]: getSoftValidationFor,
  [GetterNames.GetTimeline]: getTimeline
}

export {
  GetterNames,
  GetterFunctions
}
