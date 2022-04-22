import { convertToUnit } from 'helpers/style'

export default {
  props: {
    xSmall: {
      type: Boolean,
      default: false
    },

    small: {
      type: Boolean,
      default: false
    },

    medium: {
      type: Boolean,
      default: false
    },

    large: {
      type: Boolean,
      default: false
    },

    xLarge: {
      type: Boolean,
      default: false
    },

    size: {
      type: [Number, String],
      default: 'default'
    }
  },

  computed: {
    explicitSize () {
      const sizes = {
        xSmall: this.xSmall,
        small: this.small,
        medium: this.medium,
        large: this.large,
        xLarge: this.xLarge
      }

      return Object.keys(sizes).find(key => sizes[key])
    },

    semanticSize () {
      return this.explicitSize || 'default'
    },

    classSize () {
      return `icon-${this.semanticSize}-size`
    }
  }
}
