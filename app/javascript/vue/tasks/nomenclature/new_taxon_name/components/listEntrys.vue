<template>
  <div v-show="list.length">
    <transition-group
      class="table-entrys-list"
      name="list-complete"
      tag="ul">
      <li
        v-for="(item) in list"
        :key="item.id"
        class="list-complete-item flex-separate middle">
        <span class="list-item">
          <template v-for="show in display">
            <a
              v-if="isLink(show)"
              target="_blank"
              :href="composeLink(item, show)"
              v-html="item[show.label]"/>
            <span
              v-else
              v-html="item[show]"/>
          </template>
        </span>
        <div class="list-controls">
          <a
            :href="`/sources/${item.origin_citation.source_id}/edit`"
            target="_blank"
            v-if="getCitation(item)"
            v-html="getCitation(item)"/>
          <radial-annotator
            @close="update()"
            :global-id="item.global_id"/>
          <span
            type="button"
            title="Remove citation"
            class="circle-button button-delete btn-undo"
            v-if="getCitation(item)"
            @click="removeCitation(item)"
          />
          <span
            v-if="edit"
            type="button"
            class="circle-button btn-edit"
            @click="$emit('edit', item)"
          />
          <span
            type="button"
            class="circle-button btn-delete"
            @click="remove(item)">Remove
          </span>
        </div>
      </li>
    </transition-group>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'

export default {
  name: 'ListEntrys',

  components: {
    RadialAnnotator
  },

  props: {
    list: {
      type: Array,
      default: () => []
    },

    display: {
      type: Array
    },

    edit: {
      type: Boolean,
      default: false
    }
  },

  emits: [
    'addCitation',
    'delete',
    'update'
  ],

  methods: {
    composeLink (item, show) {
      return show.link + item[show.param]
    },

    isLink (show) {
      return !(typeof show === 'string' || show instanceof String)
    },

    update () {
      this.$emit('update')
    },

    remove (item) {
      if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
        this.$emit('delete', item)
      }
    },

    getCitation (item) {
      return item?.origin_citation?.citation_source_body || undefined
    },

    removeCitation (item) {
      const citation = {
        id: item.id,
        origin_citation_attributes: {
          id: item?.origin_citation.id || null,
          _destroy: true
        }
      }
      this.$emit('addCitation', citation)
    }
  }
}
</script>
