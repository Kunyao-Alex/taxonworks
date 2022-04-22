<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul">
    <li
      v-for="item in list"
      :key="item.id"
      class="list-complete-item flex-separate middle">
      <span
        class="list-item"
        v-html="displayName(item)"
      />
      <div class="list-controls">
        <pdf-button
          v-if="pdf && pdfExist(item)"
          :pdf="pdfExist(item)"
        />
        <radial-annotator
          v-if="annotator"
          :global-id="item.global_id"
        />
        <span
          v-if="edit"
          class="circle-button btn-edit"
          @click="emit('edit', Object.assign({}, item))"
        >
          Edit
        </span>
        <span
          class="circle-button btn-delete"
          @click="deleteItem(item)">Remove
        </span>
      </div>
    </li>
  </transition-group>
</template>
<script setup>

import PdfButton from 'components/pdfButton.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  label: {
    type: [String, Array],
    required: true
  },

  edit: {
    type: Boolean,
    default: false
  },

  pdf: {
    type: Boolean,
    default: false
  },

  annotator: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits([
  'delete',
  'edit'
])

const displayName = item => {
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

const deleteItem = item => {
  if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
    emit('delete', item)
  }
}

const pdfExist = item => {
  return item?.target_document || item?.document
}

</script>
<style lang="scss">

.list-controls {
  display: flex;
  align-items: center;
  flex-direction: row;
  justify-content: flex-end;
  .circle-button {
    margin-left: 4px !important;
  }
}

.list-item {
  white-space: normal;
  a {
    padding-left: 4px;
    padding-right: 4px;
  }
}

.table-entrys-list {
  padding: 0px;
  position: relative;

  li {
    margin: 0px;
    padding: 1em 0;
    border: 0px;
    border-bottom: 1px solid var(--border-color);
  }
}

.list-complete-item {
  justify-content: space-between;
  transition: all 0.5s, opacity 0.2s;
}

.list-complete-enter, .list-complete-leave-to {
  opacity: 0;
  font-size: 0px;
  border: none;
  transform: scale(0.0);
}

.list-complete-leave-active {
  width: 100%;
  position: absolute;
}
</style>
