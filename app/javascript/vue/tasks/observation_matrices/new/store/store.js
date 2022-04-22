import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters.js'
import { MutationFunctions } from './mutations/mutations.js'
import { ActionFunctions } from './actions/actions.js'

function makeInitialState () {
  return {
    settings: {
      loadingRows: false,
      loadingColumns: false,
      sortable: false,
      softValidations: false
    },
    configParams: {
      per: 500
    },
    matrix: {
      id: undefined,
      name: undefined,
      project_id: undefined,
      global_id: undefined
    },
    columnFixedPagination: undefined,
    rowFixedPagination: undefined,
    matrixView: 'row',
    matrixMode: 'fixed',
    matrixRowItems: [],
    matrixColumnItems: [],
    matrixRowDynamicItems: [],
    matrixColumnDynamicItems: []
  }
}

function newStore () {
  return createStore({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })
}

export {
  newStore
}
