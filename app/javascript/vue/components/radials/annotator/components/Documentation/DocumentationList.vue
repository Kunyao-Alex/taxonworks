<template>
  <table>
    <thead>
      <tr>
        <th>Filename</th>
        <th>Is public</th>
        <th>Updated at</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(item, index) in list"
        :key="item.id"
      >
        <td>
          <span v-html="item.document.object_tag" />
        </td>
        <td>
          <input
            type="checkbox"
            :checked="item.document.is_public"
            @click="changeIsPublicState(index, item)"
          >
        </td>
        <td>{{ item.updated_at }}</td>
        <td>
          <div class="horizontal-right-content">
            <radial-annotator :global-id="item.global_id" />
            <pdf-button :pdf="item.document" />
            <v-btn
              circle
              class="circle-button"
              color="primary"
              :download="item.document.object_tag"
              :href="item.document.file_url">
              <v-icon
                color="white"
                x-small
                name="download"/>
            </v-btn>
            <v-btn
              circle
              class="circle-button"
              color="destroy"
              @click="confirmDelete(item)"
            >
              <v-icon
                color="white"
                name="trash"
                x-small
              />
            </v-btn>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>

import PdfButton from 'components/pdfButton.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'

defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits('update')

const changeIsPublicState = (index, documentation) => {
  const payload = {
    id: documentation.document_id,
    is_public: !documentation.document.is_public
  }
  
  emit('update', {
    index,
    payload
  })
}

</script>
<style lang="scss">
  .radial-annotator {
    .documentation_annotator {
      textarea {
        padding-top: 14px;
        padding-bottom: 14px;
        width: 100%;
        height: 100px;
      }
      .vue-autocomplete-input {
        width: 100%;
      }
    }
  }
</style>
