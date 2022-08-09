export default (state, identifier) => {
  const index = state.identifiers.findIndex(i => i.identifier === identifier.identifier && i.identifier === identifier.identifier)

  if (index > -1) {
    state.identifiers[index] = identifier
  } else {
    state.identifiers.push(identifier)
  }

  state.lastChange = Date.now()
}
