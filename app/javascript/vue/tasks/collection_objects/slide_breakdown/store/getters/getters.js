import getSledImage from './getSledImage'
import getCollectionObject from './getCollectionObject'
import getIdentifier from './getIdentifier'
import getImage from './getImage'
import getNavigation from './getNavigation'

const GetterNames = {
  GetSledImage: 'getSledImage',
  GetIdentifier: 'getIdentifier',
  GetCollectionObject: 'getCollectionObject',
  GetImage: 'getImage',
  GetNavigation: 'getNavigation'
}

const GetterFunctions = {
  [GetterNames.GetSledImage]: getSledImage,
  [GetterNames.GetIdentifier]: getIdentifier,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetImage]: getImage,
  [GetterNames.GetNavigation]: getNavigation
}

export {
  GetterNames,
  GetterFunctions
}
