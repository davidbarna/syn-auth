###
 * Getter/Setter utility function
 * If a value is provided, then it works as a setter
 * Otherwise, it works as a getter and returns private value
 * @param  {Object} object   [description]
 * @param  {string} property Name of private property to set/get
 * @param  {?} value
 * @param  {Function} [modifier] Func to use as a setter
 * @return {?} Returns given object if setter, value if getter
###
getOrSet = ( object, property, value, modifier ) ->
  if typeof value is 'undefined'
    return object[ property ]
  else
    object[ property ] = if !!modifier then modifier( value ) else value
  return object

module.exports = getOrSet
