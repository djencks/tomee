#!/usr/bin/env node

'use strict'

const fs = require('fs')
const svnDir = '../../existing-site-svn/trunk/content'
const svnFile = `${svnDir}/old-site-stems.txt`;
const svnListFile = fs.readFileSync(svnFile).toString()

const oldDir = '../../tomee-site-generator'
const oldFile = `${oldDir}/old-jdk8-generated-site-stems.txt`;
const oldListFile = fs.readFileSync(oldFile).toString()

const noSlashRx = /([^/]*)\//g

const newListFile = fs.readFileSync('new-sitemap-addr.txt').toString()
const newPathRx = /(?<component>[^/]*)\/(?<version>[^/]*)\/(?<rel>.*)/

const unversioned = '0.x'
const unversionedOld = ['0.0', '0.1', unversioned]

// sort old file
//old()

;['admin/cluster/index',
    'latest/docs/admin/configuration/application',
    'latest/es/examples/mp-metrics-metered',
    'latest/examples/testing-security-meta',
    'latest/examples/testing-transactions',
    'master/docs/advanced/jms/jms-configuration',
    'master/pt/examples/access-timeout',
    'master/index',
    'tomee-7.0/docs/application-composer/index',
    'tomee-7.0/examples/movies-complete',
    'tomee-8.0/pt/examples/vaadin-lts-v08-simple',
    'downloads',

].forEach((file) => doAnalyzeOld(file))

function doAnalyzeOld(file) {
    // console.log(`file: ${file}`, analyzeOld(file))
}

const svnSort = oldFiles(svnListFile)
const oldSort = oldFiles(oldListFile)
const newSort = newFiles()

const result = {}

console.log('comparing svn and new')
result.svnToNew = compare(svnSort, newSort, 'svn', 'new')

console.log('\n\n\ncomparing old and new')
result.oldToNew = compare(oldSort, newSort, 'old', 'new')

console.log('\n\n\ncomparing svn and old')
result.svnToOld = compare(svnSort, oldSort, 'svn', 'old')

result.new00and01 = and(newSort['0.0@tomee'], newSort['0.1@tomee'])
result.new00notSvn = minus(newSort['0.0@tomee'], svnSort['0.0@tomee'])
result.new00toRemove = plus(result.new00and01, result.new00notSvn)
result.new00Remainng = minus(newSort['0.0@tomee'], result.new00toRemove)
result.new00Counts = {
    new00and01: result.new00and01.length,
    new00notSvn: result.new00notSvn.length,
    new00toRemove: result.new00toRemove.length
}

// console.log("RESULT: ", result)
fs.writeFileSync('comparison.json', JSON.stringify(result, null, 2))

function compare(oldSort, newSort, oldName, newName) {
    const result = {}
    Object.entries(newSort).sort(([key1, rels1], [key2, rels2]) => key1 < key2? -1: key1 === key2? 0: 1 )
        .forEach(([key, rels]) => {
        const newNameCount = `${newName}-count`
        const forKey = {}
        result[key] = forKey
        console.log(`${newName} key ${key} with count ${rels.length}`)
        forKey[`${newName}-count`] = rels.length
        const oldRels = oldSort[key]
        if (oldRels) {
            console.log(`${oldName} count ${oldRels.length}`)
            forKey[`${oldName}-count`] = oldRels.length
            const oldNotNew = oldRels.reduce((accum, rel) => {
                rels.includes(rel) || accum.push(rel)
                return accum
            }, [])
            const newNotOld = rels.reduce((accum, rel) => {
                oldRels.includes(rel) || accum.push(rel)
                return accum
            }, [])
            forKey[`${oldName}-only-count`] = oldNotNew.length
            forKey[`${oldName}-only`] = oldNotNew
            forKey[`${newName}-only-count`] = newNotOld.length
            forKey[`${newName}-only`] = newNotOld
            console.log(`${oldName} not in ${newName}: count ${oldNotNew.length}`, oldNotNew)
            console.log(`${newName} not in ${oldName}: count ${newNotOld.length}`, newNotOld)
        } else {
            console.log('no ${oldName} match for key')
        }
    })
    Object.entries(oldSort).sort(([key1, rels1], [key2, rels2]) => key1 < key2? -1: key1 === key2? 0: 1 )
        .forEach(([key, rels]) => {
        if (!newSort[key]) {
            const forKey = {}
            result[key] = forKey
            forKey[`${oldName}-count`] = rels.length
            console.log(`no ${newName} match for key ${key}: count: ${rels.length}`)
        }
    })
    return result
}

function analyzeOld(file) {
    const src = {version: unversionedOld, component: 'tomee'}
    var keyFound = false
    var stage = 0
    const rel = file.replace(noSlashRx, (match, p1) => {
        if (!keyFound) {
            // console.log(`stage ${stage} p1 ${p1}`)
            if (stage === 0) {
                stage++
                if (p1 === 'latest' || p1 === 'master') {
                    src.component = 'tomee'
                    src.version = [p1]
                    return ''
                }
                if (p1.startsWith('tomee-')) {
                    const [component, version] = p1.split('-')
                    src.component = 'tomee'
                    src.version = [version]
                    return ''
                }
                if (p1 === 'examples') {
                    src.component = p1
                    src.version = unversionedOld
                    return ''
                }
                src.component = 'tomee'
                src.version = unversionedOld
                keyFound = true
                return match
            }
            if (stage === 1) {
                stage++
                if (p1 === 'docs') {
                    keyFound = true
                    return ''
                }
                if (p1 === 'examples') {
                    src.component = 'examples'
                    keyFound = true
                    return ''
                }
                if (p1 === 'es' || p1 === 'pt') {
                    src.version[0] += '_' + p1
                    stage--
                    return ''
                }
            }
            return ''
        }
        return match
    })
    // console.log('src', src)
    return {key: src.version.map((version) => `${version}@${src.component}`), rel: rel}
}

function oldFiles(listFile) {
    const oldData = listFile.split('\n')
        .reduce((accum, file) => {
            const {key, rel} = analyzeOld(file)
            key.forEach((key) => {
                (accum[key] || (accum[key] = []) || accum[key]).push(rel)
            })
            return accum
        }, {})
    return oldData
}

function newFiles() {
    function collectFile(version, match, accum) {
        const key = `${version}@${match.groups.component}`
        var rel = match.groups.rel
        if (rel.endsWith('_es') | rel.endsWith('_pt')) {
            rel = rel.slice(0, -3)
        }
        (accum[key] || (accum[key] = []) || accum[key]).push(rel)
    }

    return newListFile.split('\n')
        .filter((file) => file)
        .reduce((accum, file) => {
            const match = file.match(newPathRx)
            const version = match.groups.version
            collectFile(version, match, accum);
            if (version === '0.0' || version === '0.1') {
                collectFile(unversioned, match, accum)
            }
            return accum
        }, {})

}

function and(arr1, arr2) {
    return arr1.filter((e) => arr2.includes(e))
}

function minus(arr1, arr2) {
    return arr1.filter((e) => !arr2.includes(e))
}

function plus(arr1, arr2) {
    return arr1.concat(minus(arr2, arr1)).sort()
}
