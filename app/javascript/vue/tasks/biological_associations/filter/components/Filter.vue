<template>
  <div class="panel vue-filter-container">
    <div
      class="flex-separate content middle action-line"
      v-hotkey="shortcuts">
      <span>Filter</span>
      <span
        data-icon="reset"
        class="cursor-pointer"
        @click="resetFilter">Reset
      </span>
    </div>
    <spinner-component
      :full-screen="true"
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="searching"
    />
    <div class="content">
      <button
        class="button button-default normal-input full_width"
        type="button"
        :disabled="emptyParams"
        @click="searchBiologicalAssociations">
        Search
      </button>
      <geographic-area
        class="margin-large-bottom margin-medium-top"
        v-model="params.geographic"
      />
      <filter-determinations
        class="margin-large-bottom"
        v-model="params.determination"/>
      <filter-identifiers
        class="margin-large-bottom"
        v-model="params.identifier"
      />
      <filter-collectors
        class="margin-large-bottom"
        v-model="params.collectors"
        role="Collector"
        title="Collectors"
        klass="CollectingEvent"
        param-people="collector_id"
        param-any="collector_ids_or"
      />
      <filter-material
        class="margin-large-bottom"
        v-model="params.types"
      />
      <filter-keywords
        class="margin-large-bottom"
        target="CollectingEvent"
        v-model="params.keywords"
      />
      <users-component
        class="margin-large-bottom"
        v-model="params.user"
      />
      <filter-attributes
        v-model="params.collectingEvents"/>
      <with-component
        class="margin-large-bottom"
        v-for="(item, key) in params.byRecordsWith"
        :key="key"
        :title="key"
        :param="key"
        v-model="params.byRecordsWith[key]"
      />
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import platformKey from 'helpers/getPlatformKey.js'

import { URLParamsToJSON } from 'helpers/url/parse.js'
import { BiologicalAssociation } from 'routes/endpoints'

export default {
  components: {
    SpinnerComponent
  },

  emits: [
    'reset',
    'newSearch',
    'result',
    'pagination',
    'urlRequest',
    'params'
  ],

  computed: {
    emptyParams () {
      return this.params === this.initParams()
    },

    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+r`] = this.resetFilter
      keys[`${platformKey()}+f`] = this.searchBiologicalAssociations

      return keys
    }
  },

  data () {
    return {
      params: this.initParams(),
      result: [],
      searching: false,
      perRequest: 10
    }
  },

  created () {
    const urlParams = URLParamsToJSON(location.href)

    if (Object.keys(urlParams).length) {
      this.getBiologicalAssociations(urlParams)
    }
  },

  methods: {
    resetFilter () {
      this.$emit('reset')
      this.params = this.initParams()
    },

    searchBiologicalAssociations () {
      if (this.emptyParams) return
      const params = this.filterEmptyParams(Object.assign({}, this.params.settings))

      this.getBiologicalAssociations(params)
    },

    getBiologicalAssociations (params) {
      this.searching = true
      this.$emit('newSearch')
      BiologicalAssociation.where(params).then(response => {
        const urlParams = new URLSearchParams(response.request.responseURL.split('?')[1])

        this.$emit('result', response.body)
        this.$emit('urlRequest', response.request.responseURL)
        this.$emit('pagination', response)
        this.$emit('params', params)

        history.pushState(null, null, `/tasks/collecting_events/filter?${urlParams.toString()}`)
        if (response.body.length === this.params.settings.per) {
          TW.workbench.alert.create('Results may be truncated.', 'notice')
        }
      }).finally(() => {
        this.searching = false
      })
    },

    initParams () {
      return {
        settings: {
          per: 500,
          page: 1
        }
      }
    },

    filterEmptyParams (object) {
      const keys = Object.keys(object)
      keys.forEach(key => {
        if (object[key] === '' || object[key] === undefined || (Array.isArray(object[key]) && !object[key].length)) {
          delete object[key]
        }
      })
      return object
    },

    flatObject (object, key) {
      const tmp = Object.assign({}, object, object[key])
      delete tmp[key]
      return tmp
    },

    loadPage (page) {
      this.params.settings.page = page
      this.searchBiologicalAssociations()
    }
  }
}
</script>
<style scoped>
:deep(.btn-delete) {
    background-color: #5D9ECE;
  }
</style>
