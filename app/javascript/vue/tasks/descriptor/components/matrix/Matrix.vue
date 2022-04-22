<template>
  <block-layout>
    <template #header>
      <h3>Include in matrix</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content">
        <div
          class="horizontal-left-content"
          v-if="matrix">
          <a
            class="margin-small-right"
            :href="`/tasks/observation_matrices/new_matrix/${matrix.id}`"
            v-html="matrix.object_tag"
          />
          <v-btn
            circle
            color="primary"
            @click="matrix = undefined"
          >
            <v-icon
              small
              name="undo"
              color="white"
            />
          </v-btn>
        </div>
        <div
          class="horizontal-left-content"
          v-else
        >
          <autocomplete
            url="/observation_matrices/autocomplete"
            param="term"
            label="label"
            placeholder="Search a observation matrix..."
            @getItem="loadMatrix($event.id)"
          />
          <default-pin
            class="margin-small-left"
            section="ObservationMatrices"
            type="ObservationMatrix"
            @getId="loadMatrix"/>
        </div>
      </div>
    </template>
  </block-layout>
</template>
<script setup>

import Autocomplete from 'components/ui/Autocomplete.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import DefaultPin from 'components/getDefaultPin.vue'
import { ObservationMatrix } from 'routes/endpoints'
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const matrix = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})


    const urlParams = new URLSearchParams(window.location.search)
    const matrixId = urlParams.get('observation_matrix_id')

    if (/^\d+$/.test(matrixId)) {
      loadMatrix(matrixId)
    }



const loadMatrix  = id => {
      ObservationMatrix.find(id).then(response => {
        matrix.value = response.body
      })
    }

</script>
