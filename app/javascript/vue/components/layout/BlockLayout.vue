<template>
  <div class="panel block-layout">
    <spinner-component
      :show-spinner="false"
      :show-legend="false"
      v-if="spinner"/>
    <a
      v-if="anchor"
      :name="anchor"
      class="anchor"/>
    <div
      class="header flex-separate middle"
      :class="{ 'validation-warning': warning }">
      <slot name="header">
        <h3>Default title</h3>
      </slot>
      <div class="horizontal-left-content">
        <slot name="options"/>
        <expand-component
          v-if="expand"
          v-model="expanded"/>
      </div>
    </div>
    <div
      class="body"
      v-show="expanded">
      <slot name="body"/>
    </div>
  </div>
</template>

<script setup>
import ExpandComponent from 'components/expand.vue'
import SpinnerComponent from 'components/spinner.vue'
import { ref } from 'vue'

defineProps({
  expand: {
    type: Boolean,
    default: false
  },

  anchor: {
    type: String,
    default: undefined
  },

  warning: {
    type: Boolean,
    default: false
  },

  spinner: {
    type: Boolean,
    default: false
  }
})

const expanded = ref(true)

</script>
<style lang="scss">
.block-layout {
  border-top-left-radius: 0px !important;
  transition: all 1s;
  height: 100%;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;

  .validation-warning {
    border-left: 4px solid #ff8c00 !important;
  }

  .create-button {
    min-width: 100px;
  }

  .header {
    border-left: 4px solid green;
    padding: var(--space-5) 0;
    padding-left: var(--space-5);
    padding-right: 1em;
    border-bottom: 1px solid #f5f5f5;

    h3 {
      font-size: var(--text-md);
      font-weight: var(--font-light);
      font-weight: var(--font-medium);
      margin: 0px;
    }
  }

  .body {
    padding: var(--space-6);
    padding-top: var(--space-2);
    padding-bottom: var(--space-2);
  }

  .taxonName-input,#error_explanation {
    width: 300px;
  }
}
</style>
