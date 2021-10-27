function parse_git_branch() {
        BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
        if [ ! "${BRANCH}" == "" ]
        then
                if [[ $(git status --porcelain) ]] ; then
                        echo -e "\e[30;48;5;208m ${BRANCH} * \e[0m"
                else
                        echo -e "\e[30;48;5;208m ${BRANCH} \e[0m"
                fi

        else
                echo ""
        fi
}

function prompt_error_code()
{
    RETVAL=$?
    [ $RETVAL -ne 0 ] && echo " $RETVAL "
}

function prompt_return_code()
{
    echo -e "\[\e[41m\]\`prompt_error_code\`\[\e[m\]"
}

function prompt_time()
{
    echo -e "\e[30;48;5;33m \@ \e[0m"

}

function prompt_user_and_hostname()
{
    echo -e "\e[30;48;5;226m \u@\h \e[0m"
}

function prompt_current_directory()
{
    echo -e "\e[30;48;5;002m 📂 \W \e[0m"

}

function prompt_same_line()
{
    echo -e "\e[30;48;5;81m ➤ \e[0m"
}

function prompt_new_line()
{
    echo -e "\n ➤ "
}

function prompt_git_branch()
{
    echo -e "`git_branch`"
}

export PS1="`prompt_return_code``prompt_user_and_hostname``prompt_current_directory`\`parse_git_branch\``prompt_new_line`"
PROMPT_COMMAND='echo -en "\033]0; $("pwd") \a"'