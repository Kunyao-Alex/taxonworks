<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th>Citation</th>
          <th />
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item">
          <td>
            <span
              :class="{ originalCitation: item.is_original }"
              v-html="item.object_tag"
            />
            <soft-validation :global-id="item.global_id"/>
          </td>
          <td>
            <div class="horizontal-right-content middle">
              <a
                class="button-default circle-button btn-citation"
                :href="`/tasks/nomenclature/by_source?source_id=${item.source_id}`"
                target="blank"/>
              <pdf-button
                v-if="item.hasOwnProperty('target_document')"
                :pdf="item.target_document"/>
              <radial-annotator :global-id="item.global_id"/>
              <span
                class="circle-button btn-edit"
                @click="$emit('edit', Object.assign({}, item))"/>
              <span
                class="circle-button btn-delete"
                @click="deleteItem(item)">Remove
              </span>
            </div>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>
<script setup>

import PdfButton from 'components/pdfButton.vue'
import SoftValidation from 'components/soft_validations/objectValidation.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'

defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits([
  'delete',
  'edit'
])


const deleteItem = item => {
  if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
    emit('delete', item)
  }
}

</script>

<style lang="scss" scoped>
  .vue-table-container {
    padding: 0px;
    position: relative;
  }

  .vue-table {
    width: 100%;
    tr {
      cursor: default;
    }
  }

  .list-complete-item {
    justify-content: space-between;
    transition: all 0.5s, opacity 0.2s;
  }

  .list-complete-enter-active, .list-complete-leave-active {
    opacity: 0;
    font-size: 0px;
    border: none;
  }
  .originalCitation {
    padding: 5px;
    border-radius: 3px;
    background-color: #006ebf;
    color: #FFF;
  }
</style>
