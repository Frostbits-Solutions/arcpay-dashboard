<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import MersenneTwister from 'mersenne-twister'
import Color from 'color'

interface Props {
  seed?: number
  diameter?: number
  address?: string | null
  shapeCount?: number
  colors?: string[]
}

const props = withDefaults(defineProps<Props>(), {
  seed: () => Math.round(Math.random() * 10000000),
  diameter: 100,
  address: null,
  shapeCount: 4,
  colors: () => [
    '#01888C', // teal
    '#FC7500', // bright orange
    '#034F5D', // dark teal
    '#F73F01', // orangered
    '#FC1960', // magenta
    '#C7144C', // raspberry
    '#F3C100', // goldenrod
    '#1598F2', // lightning blue
    '#2465E1', // sail blue
    '#F19E02', // gold
  ],
})

const jazziconRef = ref<HTMLDivElement | null>(null)
let generator: MersenneTwister | null = null
const svgns = 'http://www.w3.org/2000/svg'

const addressToNumber = (address: string): number => {
  return parseInt(address.slice(2, 10), 32)
}

const newPaper = (diameter: number, color: string) => {
  const container = document.createElement('div')
  container.style.borderRadius = `${diameter / 2}px`
  container.style.overflow = 'hidden'
  container.style.padding = '0px'
  container.style.margin = '0px'
  container.style.width = `${diameter}px`
  container.style.height = `${diameter}px`
  container.style.display = 'inline-block'
  container.style.background = color
  return { container }
}

const genColor = (colors: string[]): string => {
  const idx = Math.floor(colors.length * generator!.random())
  return colors.splice(idx, 1)[0]
}

const hueShift = (colors: string[], gen: MersenneTwister): string[] => {
  const wobble = 30
  const amount = gen.random() * 30 - wobble / 2
  return colors.map((hex) => {
    const color = Color(hex)
    color.rotate(amount)
    return color.hex()
  })
}

const genShape = (remainingColors: string[], diameter: number, i: number, total: number, svg: SVGSVGElement): void => {
  const center = diameter / 2
  const shape = document.createElementNS(svgns, 'rect')
  shape.setAttributeNS(null, 'x', '0')
  shape.setAttributeNS(null, 'y', '0')
  shape.setAttributeNS(null, 'width', String(diameter))
  shape.setAttributeNS(null, 'height', String(diameter))

  const firstRot = generator!.random()
  const angle = Math.PI * 2 * firstRot
  const velocity = (diameter / total) * generator!.random() + (i * diameter) / total
  const tx = Math.cos(angle) * velocity
  const ty = Math.sin(angle) * velocity
  const translate = `translate(${tx} ${ty})`

  const secondRot = generator!.random()
  const rot = firstRot * 360 + secondRot * 180
  const rotate = `rotate(${rot.toFixed(1)} ${center} ${center})`
  const transform = `${translate} ${rotate}`

  shape.setAttributeNS(null, 'transform', transform)
  const fill = genColor(remainingColors)
  shape.setAttributeNS(null, 'fill', fill)
  svg.appendChild(shape)
}

const generateIdenticon = (diameter: number, seed: number): HTMLDivElement => {
  generator = new MersenneTwister(seed)
  const remainingColors = hueShift(props.colors.slice(), generator)
  const elements = newPaper(diameter, genColor(remainingColors))
  const container = elements.container

  const svg = document.createElementNS(svgns, 'svg')
  svg.setAttributeNS(null, 'x', '0')
  svg.setAttributeNS(null, 'y', '0')
  svg.setAttributeNS(null, 'width', String(diameter))
  svg.setAttributeNS(null, 'height', String(diameter))
  container.appendChild(svg)

  for (let i = 0; i < props.shapeCount - 1; i++) {
    genShape(remainingColors, diameter, i, props.shapeCount - 1, svg)
  }

  return container
}

const icon = async (): Promise<void> => {
  const seed = props.address ? addressToNumber(props.address) : props.seed
  if (jazziconRef.value) {
    jazziconRef.value.innerHTML = ''
    const el = generateIdenticon(props.diameter, seed)
    jazziconRef.value.appendChild(el)
  }
}

watch(() => props.seed, icon)
watch(() => props.address, icon)
watch(() => props.diameter, icon)

onMounted(() => {
  icon()
})
</script>

<template>
  <div ref="jazziconRef" />
</template>
