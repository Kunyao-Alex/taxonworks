import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

function makeInitialState () {
  return {
    content: {
      otu_id: undefined,
      topic_id: undefined,
      text: undefined
    },
    selected: {
      content: undefined,
      topic: undefined,
      otu: undefined
    },
    panels: {
      figures: false,
      citations: false
    },
    depictions: [],
    citations: []
  }
}

function newStore () {
  return createStore({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions
  })
}

export {
  newStore
}
