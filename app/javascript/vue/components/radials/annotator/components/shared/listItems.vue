<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul">
    <li
      v-for="item in list"
      :key="item.id"
      class="list-complete-item flex-separate middle"
      :class="{ 'highlight': checkHighlight(item) }"
    >
      <span
        class="list-item"
        v-html="displayName(item)"/>
      <div class="list-controls">
        <citations-count
          :target="targetCitations"
          :object="item"/>
        <radial-annotator
          v-if="annotator"
          :global-id="item.global_id"/>
        <span
          v-if="edit"
          class="circle-button btn-edit"
          @click="emit('edit', Object.assign({}, item))">Edit
        </span>
        <span
          v-if="remove"
          class="circle-button btn-delete"
          @click="deleteItem(item)">Remove
        </span>
      </div>
    </li>
  </transition-group>
</template>

<script setup>

import CitationsCount from './citationsCount.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },
  annotator: {
    type: Boolean,
    default: true
  },
  targetCitations: {
    type: String,
    required: true
  },
  label: {
    type: [String, Array],
    required: true
  },
  edit: {
    type: Boolean,
    default: false
  },
  remove: {
    type: Boolean,
    default: true
  },
  annotator: {
    type: Boolean,
    default: false
  },
  highlight: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['edit', 'delete'])

const displayName = item => {
  if (typeof props.label === 'string') {
    return item[props.label]
  } else {
    let tmp = item

    props.label.forEach(label => { tmp = tmp[label] })

    return tmp
  }
}

const checkHighlight = item => {
  if (props.highlight) {
    return props.highlight.key
      ? props[props.highlight.key] == props.highlight.value
      : item == props.highlight.value
  }
  return false
}

const deleteItem = item => {
  if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
    emit('delete', item)
  }
}

</script>
