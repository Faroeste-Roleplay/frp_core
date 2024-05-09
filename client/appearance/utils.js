
const mergeArrData = (arr, data) => {
    return [ ...arr, ...data];
}
exports("mergeArrData", mergeArrData)

const mergeObjectData = (obj, data) => {
    return { ...obj, ...data }
}
exports("mergeObjectData", mergeObjectData)


const camelToSnakeCase = str => str.replace(/[A-Z]/g, (letter, index) => { return index == 0 ? letter.toLowerCase() : '_'+ letter.toLowerCase();});;
exports('camelToSnakeCase', camelToSnakeCase)

// HELLO WORLD -> Hello World
function titleCaseWord(mySentence)
{
    const words = mySentence.split(' ');

    for (let i = 0; i < words.length; i++)
    {
        words[i] = words[i][0].toUpperCase() + words[i].substr(1);
    }

    return words.join(' ');
}
exports('titleCaseWord', titleCaseWord)


// HELLO_WORLD -> helloWorld
const snakeToCamel = (str) => str.toLowerCase().replace( /([-_]\w)/g, g => g[ 1 ].toUpperCase() );
exports('snakeToCamel', snakeToCamel)

// HELLO_WORLD -> HelloWorld
const snakeToPascal = (str) =>
{
    let camelCase = snakeToCamel( str );
    let pascalCase = camelCase[ 0 ].toUpperCase() + camelCase.substr( 1 );
    return pascalCase;
}
exports('snakeToPascal', snakeToPascal)