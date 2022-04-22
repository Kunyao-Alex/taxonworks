<template>
  <ul class="tree-status">
    <li
      v-for="(item, key) in orderList"
      :key="key">
      <button
        v-if="item.hasOwnProperty(display)"
        type="button"
        :value="item.type"
        @click="emit('selected', item)"
        :disabled="((item.disabled || !!alreadyCreated(item)) || isForThisRank(item))"
        class="button button-submit normal-input">
        {{ item[display] }}
      </button>
      <recursive-list
        v-if="isObject(item)"
        :created-list="createdList"
        :display="display"
        :valid-property="validProperty"
        :object-list="item"
        :taxon-rank="taxonRank"
        @selected="$emit('selected', $event)"
      />
    </li>
  </ul>
</template>

<script setup>
import { computed } from 'vue'
import RecursiveList from './recursiveList.vue'

const props = defineProps({
  objectList: {
    type: Object,
    required: true
  },

  display: {
    type: String,
    required: true
  },

  validProperty: {
    type: String,
    required: true
  },

  createdList: {
    type: Array,
    default: () => []
  },

  taxonRank: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['selected'])

const orderList = computed(() => {
  const sortable = []
  const sortableObject = {}

  for (const key in props.objectList) {
    sortable.push([key, props.objectList[key]])
  }

  sortable.sort((a, b) => {
    if (a[1][props.display] > b[1][props.display]) {
      return 1
    }
    if (a[1][props.display] < b[1][props.display]) {
      return -1
    }
    return 0
  })

  sortable.forEach(item => {
    sortableObject[item[0]] = item[1]
  })

  return sortableObject
})

const alreadyCreated = status => props.createdList.find(element => element.type === status.type)

const isForThisRank = item => item[props.validProperty] && !(item[props.validProperty].includes(props.taxonRank))

const isObject = item => typeof item === 'object'

</script>
