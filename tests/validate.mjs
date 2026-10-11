import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const lua=process.argv[2]||'lua';
const luac=process.argv[3]||'luac';
function parseJsonc(s){return JSON.parse(s.replace(/^\uFEFF/,'').replace(/"(?:\\.|[^"\\])*"|\/\/[^\r\n]*|\/\*[\s\S]*?\*\//g,m=>m.startsWith('/')?'':m).replace(/,\s*([}\]])/g,'$1'));}
function walk(dir){return fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.name==='.git'?[]:e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]);}
const files=walk(root);
const docs=Object.fromEntries(files.filter(p=>/\.jsonc?$/.test(p)).map(p=>[path.relative(root,p).replaceAll('\\','/'),parseJsonc(fs.readFileSync(p,'utf8'))]));
const core=fs.readFileSync(path.join(root,'scripts/autotracking/archipelago.lua'),'utf8');
const itemTable=core.match(/local ITEM_MAPPING = \{([\s\S]*?)\n\}/)[1];
const items=[...itemTable.matchAll(/\[(\d+)\]\s*=\s*"([^"@][^"]*)"/g)].map(m=>({id:+m[1],code:m[2]}));
const locations=[...core.matchAll(/\[(\d+)\]\s*=\s*"(@[^"]+)"/g)].map(m=>({id:+m[1],code:m[2]}));
const weapons=[...core.match(/local PROGRESSIVE_WEAPONS = \{([\s\S]*?)\}/)[1].matchAll(/"([^"]+)"/g)].map(m=>m[1]);
const codes=new Set();
for(const item of docs['items/items.jsonc'])for(const code of (item.codes||'').split(',').filter(Boolean)){assert(!codes.has(code),'Duplicate item '+code);codes.add(code);}
const sections=new Set();
function index(nodes,parent=''){for(const node of nodes){const here=parent+'/'+node.name;for(const section of node.sections||[]){const code='@'+here.slice(1)+'/'+section.name;assert(!sections.has(code),'Duplicate section '+code);sections.add(code);}index(node.children||[],here);}}
index(docs['locations/missions.jsonc']);
for(const m of items)assert(codes.has(m.code),'Missing item '+m.code);
for(const m of locations)assert(sections.has(m.code),'Missing section '+m.code);
assert.equal(new Set(items.map(m=>m.id)).size,items.length,'Duplicate item IDs');
assert.equal(new Set(locations.map(m=>m.id)).size,locations.length,'Duplicate location IDs');
assert.equal(new Set(locations.map(m=>m.code)).size,locations.length,'Duplicate location targets');
function refs(value){if(!value||typeof value!=='object')return;for(const [key,v] of Object.entries(value)){if(key==='ref')assert(sections.has('@'+v.replace(/^@/,'')),'Missing reference '+v);if(key==='img'||key.endsWith('_img'))assert(fs.existsSync(path.join(root,v.split(':')[0])),'Missing image '+v);refs(v);}}
Object.values(docs).forEach(refs);
function run(exe,args,input){const result=spawnSync(exe,args,{cwd:root,input,encoding:'utf8'});if(result.error)throw result.error;assert.equal(result.status,0,result.stderr);return result.stdout;}
for(const file of files.filter(p=>p.endsWith('.lua')))run(luac,['-p',file]);
function value(v){if(v===null)return 'nil';if(typeof v==='string')return JSON.stringify(v);if(typeof v==='boolean'||typeof v==='number')return String(v);if(Array.isArray(v))return '{'+v.map(value).join(',')+'}';return '{'+Object.entries(v).map(([k,x])=>'['+value(k)+']='+value(x)).join(',')+'}';}
const fixture='DOCS='+value(docs)+'\nITEMS='+value(items)+'\nLOCATIONS='+value(locations)+'\nWEAPONS='+value(weapons)+'\n';
const output=run(lua,['-'],fixture+fs.readFileSync(path.join(root,'tests/ap_callbacks.lua'),'utf8'));
console.log(output.split(/\r?\n/).filter(line=>line.startsWith('PASS')).join('\n'));
console.log('PASS syntax, JSON, references, '+items.length+' item mappings, '+locations.length+' location mappings');
console.log('Offline simulation only. This does not test a live AP connection or PopTracker rendering.');
