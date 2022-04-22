<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul">
    <li
      v-for="(item, index) in list"
      :key="setKey ? item[setKey] : item.id || JSON.stringify(item)"
      class="list-complete-item flex-separate middle"
      :class="{ 'highlight': checkHighlight(item) }">
      <span>
        <soft-validation
          v-if="validations"
          :global-id="item.global_id"/>
        <span
          class="list-item"
          v-html="displayName(item)"/>
      </span>
      <div class="list-controls">
        <slot
          name="options"
          :item="item"/>
        <a
          v-if="download"
          class="btn-download circle-button"
          :href="getPropertyValue(item, download)"
          download
        />
        <radial-annotator
          v-if="annotator"
          :global-id="item.global_id"/>
        <radial-object
          v-if="radialObject && item.hasOwnProperty('global_id')"
          :global-id="item.global_id"/>
        <span
          v-if="edit"
          class="circle-button btn-edit"
          @click="emit('edit', Object.assign({}, item))">Edit
        </span>
        <span
          v-if="remove"
          class="circle-button btn-delete"
          :class="{ 'button-default': softDelete }"
          @click="deleteItem(item, index)">Remove
        </span>
      </div>
    </li>
  </transition-group>
</template>
<script setup>

import RadialObject from 'components/radials/navigation/radial.vue'
import SoftValidation from 'components/soft_validations/objectValidation.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },
  download: {
    type: String,
    default: undefined
  },
  label: {
    type: [String, Array],
    default: undefined
  },
  setKey: {
    type: String,
    default: undefined
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
  radialObject: {
    type: Boolean,
    default: false
  },
  highlight: {
    type: Object,
    default: undefined
  },
  deleteWarning: {
    type: Boolean,
    default: true
  },
  validations: {
    type: Boolean,
    default: false
  },
  softDelete: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits([
  'delete',
  'deleteIndex',
  'edit'
])

const displayName = item => {
  if (!props.label) return item
  if (typeof props.label === 'string') {
    return item[props.label]
  } else {
    let tmp = item

    props.label.forEach(label => {
      tmp = tmp[label]
    })

    return tmp
  }
}

const checkHighlight = item => {
  if (props.highlight) {
    return props.highlight.key 
      ? item[props.highlight.key] == props.highlight.value
      : item == props.highlight.value
  }

  return false
}

const deleteItem = (item, index) => {
  if(props.deleteWarning) {
    if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
      emit('delete', item)
      emit('deleteIndex', index)
    }
  } else {
    emit('delete', item)
    emit('deleteIndex', index)
  }
}

const getPropertyValue = (item, stringPath) => {
  let keys = stringPath.split('.')

  if (keys.length === 1) {
    return item[stringPath]
  } else {
    let value = item
    
    keys.forEach(key => { value = value[key] })

    return value
  }
}

</script>
