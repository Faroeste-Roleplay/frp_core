
function handleApparatusChangeAnimation(ped, type)
{
    if (type === eMetapedBodyApparatusType.Teeth)
    {
        requestAnimDict('FACE_HUMAN@GEN_MALE@BASE').then(() =>
        {
            TaskPlayAnim(ped, 'FACE_HUMAN@GEN_MALE@BASE', 'Face_Dentistry_Loop',  8.0, -8.0, -1, 16, 0.0, false, 0, false, 0, false);
        });

        return;
    }

    ClearPedTasks(ped, 0, 0);
}

async function requestAnimDict(animDict) {
    return new Promise( (resolve) => {
            if (!DoesAnimDictExist(animDict))
                resolve(false);
            
            if (HasAnimDictLoaded(animDict)) {
                resolve(true);
            } else {
                RequestAnimDict(animDict);

                const intervalHandle = setInterval(() => {
                    if (HasAnimDictLoaded(animDict)) {
                        clearInterval(intervalHandle);

                        resolve(true);
                    }
                },
                0);
            }
        }
    );
}

const camelToSnakeCase = str => str.replace(/[A-Z]/g, (letter, index) => { return index == 0 ? letter.toLowerCase() : '_'+ letter.toLowerCase();});;

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

async function setManagedPromiseTick(callback, timeout) {
    let timerTick;
    let timerTimeout;

    try {
        return await new Promise((resolve, reject) => {
            timerTick = setTick(() => {
                try {
                    callback(resolve, reject);
                } catch (e) {
                    reject(new Error(`Ocorreu um error dentro do callback de um managed promise tick: ${e.message}`));
                }
            });

            if (timeout) {
                timerTimeout = setTimeout(() => {
                    reject(new Error('Managed promise tick deu timeout!'));
                }, timeout);
            }
        });
    } catch (e) {
        throw e;
    } finally {
        clearTick(timerTick);
        clearTimeout(timerTimeout);
    }
}
