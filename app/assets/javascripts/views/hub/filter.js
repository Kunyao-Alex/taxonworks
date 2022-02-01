var TW = TW || {};
TW.views = TW.views || {};
TW.views.hub = TW.views.hub || {};
TW.views.hub.filter = TW.views.hub.filter || {};

Object.assign(TW.views.hub.filter, {
  filterHubTask: undefined,

  init: function() {
    this.filterHubTask = new FilterHub()
    this.resizeTaskCarrouselEvent = this.resizeTaskCarrousel.bind(this)

    if (document.querySelector('#task_carrousel')) {
      this.resizeTaskCarrousel()
      this.handleEvents()
    }

    this.loadCategoriesIcons()
  },

  resizeTaskCarrousel() {
    const userWindowWidth = $(window).width();
    const userWindowHeight = $(window).height();
    const minWindowWidth = ($('#favorite-page').length ? 1000 : 700);
    const cardWidth = 427.5
    const cardHeight = 180
    const taskSectionElement = document.querySelector('.task-section')

    if (!taskSectionElement) {
      return
    }

    let tmpHeight = userWindowHeight - taskSectionElement.offsetTop
    tmpHeight = tmpHeight / cardHeight

    if (userWindowWidth < minWindowWidth) {
      if (document.querySelector('#favorite-page')) {
        this.filterHubTask.changeTaskSize(1)
      } else {
        this.filterHubTask.changeTaskSize(1, Math.floor(tmpHeight))
      }
    } else {
      const tmp = (userWindowWidth - minWindowWidth) / cardWidth

      if (tmp > 0) {
        if (document.querySelector('#favorite-page')) {
          this.filterHubTask.changeTaskSize(Math.ceil(tmp))
        } else {
          this.filterHubTask.changeTaskSize(Math.ceil(tmp), Math.floor(tmpHeight))
        }
      }
    }
  },

  handleEvents () {
    window.addEventListener('resize', this.resizeTaskCarrouselEvent)
  },

  removeEvents () {
    window.removeEventListener('click', this.resizeTaskCarrouselEvent)
  },

  loadCategoriesIcons () {
    const DATE_TYPES = [
      'collecting_event',
      'nomenclature',
      'collection_object',
      'source',
      'biology',
      'matrix',
      'dna',
      'image'
    ]

    DATE_TYPES.forEach(type => {
      const elements = [...document.querySelectorAll(`.data_card [data-category-${type}]`)]

      elements.forEach(element => {
        const iconElement = document.createElement('span')

        iconElement.classList.add(
          'filter-category-icon',
          type
        )
        element.append(iconElement)
      })
    })
  }
})

$(document).on('turbolinks:load', () => {
  if (document.querySelector('#data_cards') || document.querySelector('#task_carrousel')) {
    TW.views.hub.filter.init()
  }
})
