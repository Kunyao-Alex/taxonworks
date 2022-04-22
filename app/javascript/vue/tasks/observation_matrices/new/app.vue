<template>
  <div id="vue_new_matrix_task">
    <spinner-component
      v-if="settings.loadingRows || settings.loadingColumns"
      legend="Loading..."
      :full-screen="true"/>
    <div class="flex-separate middle">
      <h1>{{ (matrix.id ? 'Edit' : 'New') }} observation matrix</h1>
      <div class="horizontal-left-content">
        <ul class="context-menu">
          <li>
            <a
              :href="routeNames.ObservationMatricesHub">
              Hub
            </a>
          </li>
          <li>
            <a
              :href="routeNames.ObservationMatricesDashboard">
              Dashboard
            </a>
          </li>
          <li>
            <a :href="`/tasks/observation_matrices/view/${matrix.id}`">
              View
            </a>
          </li>

          <li>
            <a href="/otus/new">New OTU</a>
          </li>
          <li>
            <a
              v-if="matrix.id"
              :href="`/tasks/descriptors/new_descriptor?observation_matrix_id=${matrix.id}`">New descriptor
            </a>
            <a
              v-else
              :href="`/tasks/descriptors/new_descriptor`">New descriptor
            </a>
          </li>
          <li>
            <a href="/tasks/accessions/comprehensive/index">New collection object</a>
          </li>
          <li v-if="matrix.id && settings.sortable">
            <button
              type="button"
              class="button normal-input button-submit"
              @click="sortRows(matrix.id)">
              Sort by nomenclature
            </button>
          </li>
          <li>
            <label class="middle">
              <input
                v-model="settings.softValidations"
                type="checkbox">
              Validation
            </label>
          </li>
          <li>
            <label class="middle">
              <input
                v-model="settings.sortable"
                type="checkbox">
              Sortable columns/rows
            </label>
          </li>
          <template v-if="matrix.id">
            <li>
              <pin-component
                :object-id="matrix.id"
                :type="matrix.base_class"
                section="ObservationMatrices"
              />
            </li>
            <li>
              <radial-navigation
                type="annotations"
                :global-id="matrix.global_id"/>
            </li>
            <li>
              <radial-annotator
                type="annotations"
                :global-id="matrix.global_id"/>
            </li>
          </template>
        </ul>
      </div>
    </div>
    <div class="horizontal-left-content align-start">
      <div class="cleft margin-medium-right">
        <new-matrix/>
        <div
          v-if="matrix.id"
          class="margin-medium-top">
          <component
            v-if="isRowView"
            :is="`rows-${matrixMode}`"/>
          <component
            v-else
            :is="`columns-${matrixMode}`"/>
        </div>
      </div>
      <tables-component v-if="matrix.id" />
    </div>
  </div>
</template>

<script>

import NewMatrix from './components/newMatrix/newMatrix.vue'
import TablesComponent from './components/tables/view.vue'
import RowsFixed from './components/rows/fixed.vue'
import columnsFixed from './components/columns/fixed.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import PinComponent from 'components/ui/Pinboard/VPin.vue'
import SpinnerComponent from 'components/spinner.vue'
import RadialNavigation from 'components/radials/navigation/radial.vue'

import RowsDynamic from './components/rows/dynamic.vue'
import ColumnsDynamic from './components/columns/dynamic.vue'

import { SortMatrixByNomenclature } from './request/resources.js'
import { GetterNames } from './store/getters/getters.js'
import { ActionNames } from './store/actions/actions.js'
import { RouteNames } from 'routes/routes'

export default {
  name: 'NewObservationMatrix',

  components: {
    NewMatrix,
    RowsFixed,
    RowsDynamic,
    TablesComponent,
    columnsFixed,
    ColumnsDynamic,
    RadialAnnotator,
    PinComponent,
    SpinnerComponent,
    RadialNavigation
  },

  computed: {
    matrix () {
      return this.$store.getters[GetterNames.GetMatrix]
    },
    isRowView () {
      return this.$store.getters[GetterNames.GetMatrixView] === 'row'
    },
    matrixMode () {
      return this.$store.getters[GetterNames.GetMatrixMode]
    },
    settings () {
      return this.$store.getters[GetterNames.GetSettings]
    },
    routeNames () {
      return RouteNames
    }
  },

  data () {
    return {
      loading: false
    }
  },

  created () {
    const matrixId = location.pathname.split('/')[4]

    if (/^\d+$/.test(matrixId)) {
      this.loading = true
      this.$store.dispatch(ActionNames.LoadMatrix, matrixId).finally(() => {
        this.loading = false
      })
    }
  },

  methods: {
    sortRows (matrixId) {
      SortMatrixByNomenclature(matrixId).then(_ => {
        this.$store.dispatch(ActionNames.GetMatrixObservationRows, { per: 500 })
      })
    }
  }
}

</script>
<style lang="scss">
  #vue_new_matrix_task {
    flex-direction: column-reverse;
    margin: 0 auto;
    margin-top: 1em;

    .cleft, .cright {
      min-width: 500px;
      max-width: 500px;
      width: 450px;
    }

    .anchor {
       display:block;
       height:65px;
       margin-top:-65px;
       visibility:hidden;
    }
    hr {
        height: 1px;
        color: #f5f5f5;
        background: #f5f5f5;
        font-size: 0;
        margin: 15px;
        border: 0;
    }

    table {
      min-width: 500px;
      width: 100%;
    }

    .matrix-tables {
      overflow-y: auto;
      max-height: calc(100vh - 200px);
      min-width: fit-content;
    }
  }
</style>
