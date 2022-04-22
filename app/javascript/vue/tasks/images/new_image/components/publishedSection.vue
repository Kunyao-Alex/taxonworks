<template>
  <div class="panel content">
    <h2>Published in</h2>
    <smart-selector
      :options="options"
      v-model="view"/>
    <role-picker
      v-model="roles_attributes"/>
  </div>
</template>

<script>

import SmartSelector from 'components/switch.vue'
import RolePicker from 'components/role_picker.vue'

export default {
  components: {
    SmartSelector,
    RolePicker
  },

  props: {
    title: {
      type: String,
      required: true
    }
  },

  data() {
    return {
      options: [],
      view: undefined,
      roles_attributes: []
    }
  }
}
</script>
