import ActionNames from './actionNames'

import importRow from './importRow'
import loadDataset from './loadDataset'
import loadDatasetRecords from './loadDataSetRecords'
import loadNamespace from './loadNamespace'
import loadNamespaces from './loadNamespaces'
import updateRow from './updateRow'
import processImport from './processImport'
import updateCatalogNumberNamespace from './updateCatalogNumberNamespace'
import updateDefaultCatalogNumber from './updateDefaultCatalogNumber'
import resetState from './resetState'

const ActionFunctions = {
  [ActionNames.ImportRow]: importRow,
  [ActionNames.LoadDataset]: loadDataset,
  [ActionNames.LoadDatasetRecords]: loadDatasetRecords,
  [ActionNames.LoadNamespace]: loadNamespace,
  [ActionNames.LoadNamespaces]: loadNamespaces,
  [ActionNames.UpdateCatalogNumberNamespace]: updateCatalogNumberNamespace,
  [ActionNames.UpdateDefaultCatalogNumber]: updateDefaultCatalogNumber,
  [ActionNames.UpdateRow]: updateRow,
  [ActionNames.ProcessImport]: processImport,
  [ActionNames.ResetState]: resetState
}

export {
  ActionFunctions,
  ActionNames
}
