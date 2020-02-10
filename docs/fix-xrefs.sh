#!/usr/bin/env node

'use strict'

const version = '8.0'
const sourcepath = 'tomee/'
const pagesPath = sourcepath + 'modules/ROOT/pages/'
const fs = require('fs')

const errorRx = /path\: (:?docs\/tomee\/)?(?<path>.*) \| xref\: (?<xref>.*)/

const indexFile = fs.readFileSync('new-antora-index.txt').toString()
const index = indexFile.split('\n').reduce((accum, line) => {
  const [key, value] = line.split(' ')
  var values = accum[key]
  if (!values) {
    values = []
    accum[key] = values
  }
  values.push(value)
  return accum
  }, [])
console.log('index', index)
const errors = fs.readFileSync('xref-errors.txt').toString()

const lines = errors.split('\n')
console.log('linecount: ', lines.length)
var lineNo = 0
var inVersion = false
lines.filter((line) => {
  lineNo++
  if (line.length === 0) {
    inVersion = false
  }
  const result = inVersion
  if (line.endsWith(`version: ${version}`)) {
    inVersion = true
  }
  return result
}).forEach((line) => {
  console.log('line', line)
  const found = line.match(errorRx)
//  console.log('found', found)
  if (found.groups) {
    const path = sourcepath + found.groups.path
    const content = fs.readFileSync(path).toString()
    const repl = content.replace(`xref:${found.groups.xref}`, (match, offset) => {
//      console.log('found xref at ' + offset)
        var target = found.groups.xref
        if (target.startsWith(':')) target = target.slice(1)
        const dir = path.slice(path.indexOf('pages/') + 6, path.lastIndexOf('/') + 1)
        console.log(`trimmed ${path} to ${dir}, trying `)
        try {
          const stat = fs.statSync(`${pagesPath}${dir}${target}`)
          console.log('returning 1 ', `xref:${dir}${target}`)
          return `xref:${dir}${target}`
        } catch (err) {
          //console.log('error ' + err)
        }
        //look in index
        const key = found.groups.xref.includes('/') ?
          found.groups.xref.substring(found.groups.xref.lastIndexOf('/')+ 1,
          found.groups.xref.length) : found.groups.xref
        const values = index[key]
        if (values) {
          if (values.length === 1) {
          console.log('returning 2 ', `xref:${values[0]}`)
            return `xref:${values[0]}`
          }
          const result = `
//FIXME CHOOSE ONE
${values.map((value) => `xref:${value}`).join('[]\n')}`
           console.log('returning 3 ', result)
           return result
        }
        console.log('nothing found')
        return match
    })
    fs.writeFileSync(path, repl)
  } else {
    console.log(`no match found for line ${lineNo} ${line}`)
  }
})


