// Point in polygon check using ray-casting algorithm
const isPointInPolygon = (point, polygon) => {
  const { lat, lng } = point;
  let inside = false;

  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const xi = polygon[i].lat;
    const yi = polygon[i].lng;
    const xj = polygon[j].lat;
    const yj = polygon[j].lng;

    const intersect =
      yi > lng !== yj > lng &&
      lat < ((xj - xi) * (lng - yi)) / (yj - yi + 0.0000001) + xi;

    if (intersect) inside = !inside;
  }

  return inside;
};

module.exports = { isPointInPolygon };